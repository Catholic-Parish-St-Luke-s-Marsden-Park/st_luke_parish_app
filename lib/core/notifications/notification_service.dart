import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kReleaseMode, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_helpers.dart';

/// Owns push notification setup: permissions, foreground display, and
/// registering this device's FCM token with the backend.
/// A singleton, so listeners are only attached once per app run.
///
/// Tapping a notification only opens the app for now. Each notification's
/// payload still carries the message data (see
/// [NotificationHelpers.encodePayload]) so routing can be added when a
/// feature needs it.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  NotificationService._()
    : _httpClient = http.Client(),
      _isRelease = kReleaseMode,
      _retryDelayUnit = const Duration(seconds: 2);

  /// Test-only: bypasses the singleton so tests can inject a fake HTTP client,
  /// control release-mode behaviour and skip retry backoff without touching
  /// the shared instance every other part of the app uses.
  @visibleForTesting
  NotificationService.forTesting({
    required http.Client httpClient,
    required bool isRelease,
    Duration retryDelayUnit = Duration.zero,
  }) : _httpClient = httpClient,
       _isRelease = isRelease,
       _retryDelayUnit = retryDelayUnit;

  final http.Client _httpClient;
  final bool _isRelease;

  /// Backoff between registration attempts is `attempt * _retryDelayUnit`.
  final Duration _retryDelayUnit;

  /// Device registration endpoint (including `/v1/devices`) from BASE_URL in assets/app.env.
  /// Null, with the reason logged, if it is missing, malformed, or (in release
  /// builds) not https, so misconfiguration isn't retried as a network error.
  /// dotenv throws if assets/app.env never loaded (main.dart logs and carries
  /// on), so that case is treated as a missing BASE_URL.
  Uri? get _backendUri => resolveBackendUri(
    dotenv.isInitialized ? dotenv.maybeGet('BASE_URL') : null,
    isRelease: _isRelease,
  );

  /// Validates and parses a raw BASE_URL value into the token endpoint.
  /// Pulled out of [_backendUri] as a pure function so the validation rules
  /// are unit-testable without touching dotenv or kReleaseMode.
  @visibleForTesting
  static Uri? resolveBackendUri(String? raw, {required bool isRelease}) {
    final trimmed = raw?.trim();
    final uri = (trimmed == null || trimmed.isEmpty)
        ? null
        : Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      debugPrint('BASE_URL is missing or invalid in assets/app.env.');
      return null;
    }
    if (isRelease && uri.scheme != 'https') {
      debugPrint('BASE_URL must use https in release builds.');
      return null;
    }
    return uri;
  }

  /// SharedPreferences key holding the last token the backend accepted, used
  /// to skip redundant registrations.
  static const _tokenPrefsKey = 'last_registered_fcm_token';

  // Late so constructing the service (e.g. via forTesting) doesn't require
  // Firebase.initializeApp to have run; only the FCM-facing methods touch it.
  late final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;

  StreamSubscription<String>? _tokenRefreshSub;

  /// Sets up the local notifications plugin, the Android channel and the FCM
  /// listeners. Idempotent. Does not ask for permission; see [setup].
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _plugin = FlutterLocalNotificationsPlugin();
      await _plugin!.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Permissions are requested explicitly in requestPermission(), not
          // as a side effect of initialisation.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      if (Platform.isAndroid) {
        await _createChannel();
      }
      await _setupListeners();
      _initialized = true;
    } catch (e) {
      debugPrint('Init error: $e');
      rethrow;
    }
  }

  /// Ensures [initialize] has run, then requests permission and registers
  /// this device's token with the backend.
  Future<void> setup() async {
    if (!_initialized) {
      await initialize();
    }
    await requestPermission();
    await registerDevice();
  }

  Future<void> _createChannel() async {
    final channel = NotificationHelpers.createChannel();
    await _plugin!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupListeners() async {
    if (Platform.isIOS) {
      // iOS shows foreground pushes natively when told to; _showForeground
      // skips iOS so the user doesn't get a duplicate local notification.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    // Message received while the app is open (FCM shows nothing on Android).
    FirebaseMessaging.onMessage.listen(_showForeground);
  }

  /// Requests notification permission. Does not fetch or send the token;
  /// call [registerDevice] for that.
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        debugPrint('Notification permission granted.');
        break;
      case AuthorizationStatus.denied:
      case AuthorizationStatus.deniedPermanently:
        debugPrint('Notification permission denied.');
        break;
      case AuthorizationStatus.notDetermined:
        debugPrint('Notification permission not determined.');
        break;
    }

    return settings;
  }

  Future<void> _showForeground(RemoteMessage message) async {
    if (Platform.isIOS) return;
    if (_plugin != null) {
      await NotificationHelpers.showNotification(message, _plugin!);
    }
  }

  /// On iOS the FCM token can only be issued once APNs has handed the device
  /// an APNs token, which can lag behind permission being granted. Polls
  /// briefly; returns false if it never arrives (e.g. simulator without
  /// push support, or missing Push Notifications capability).
  Future<bool> _waitForApnsToken({int attempts = 10}) async {
    for (var i = 0; i < attempts; i++) {
      if (await _messaging.getAPNSToken() != null) return true;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }

  /// Returns this device's current FCM token, or null if unavailable.
  Future<String?> getToken() => _messaging.getToken();
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  void dispose() {
    _tokenRefreshSub?.cancel();
  }

  /// Registers this device's FCM token with the backend, and keeps it
  /// updated if the token changes later. Safe to call more than once.
  Future<void> registerDevice() async {
    try {
      if (Platform.isIOS && !await _waitForApnsToken()) {
        debugPrint('APNs token unavailable; relying on token refresh.');
      } else {
        final token = await _messaging.getToken();
        if (token != null) {
          await sendTokenIfChanged(token);
        }
      }
    } catch (e) {
      // Logged rather than rethrown: a token failure shouldn't stop the
      // refresh listener below from being attached.
      debugPrint('Could not fetch FCM token: $e');
    }

    // Cancel any existing subscription first so repeated calls to
    // registerDevice() don't stack duplicate listeners.
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed.');
      // Unlike the caught-and-swallowed failure above, nothing awaits this
      // listener callback, so an uncaught error here would surface as an
      // uncaught zone error (a debug-mode red screen) instead of a log line.
      unawaited(
        sendTokenIfChanged(newToken).catchError((Object e) {
          debugPrint('Failed to handle refreshed token: $e');
        }),
      );
    });
  }

  /// Sends [token] to the backend only if it, together with the backend
  /// endpoint, differs from the last successfully registered pair — so
  /// switching BASE_URL (e.g. emulator to production) forces a fresh
  /// registration instead of being skipped as "unchanged".
  @visibleForTesting
  Future<void> sendTokenIfChanged(String token) async {
    final uri = _backendUri;
    if (uri == null) return;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$token@${uri.origin}';
    final lastSent = prefs.getString(_tokenPrefsKey);
    if (lastSent == cacheKey) {
      debugPrint('FCM token unchanged, skipping registration.');
      return;
    }

    final success = await postToken(uri, token);
    if (success) {
      await prefs.setString(_tokenPrefsKey, cacheKey);
    } else {
      debugPrint('FCM token registration gave up after retries.');
    }
  }

  /// Body for `POST /v1/devices`. Topics are omitted so the server keeps any
  /// it has stored. [platform] is injectable for tests.
  @visibleForTesting
  Map<String, Object> buildRegistrationBody(String token, {String? platform}) {
    return {
      'fcmToken': token,
      'platform': platform ?? (Platform.isIOS ? 'ios' : 'android'),
      'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
    };
  }

  String _describeProblem(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        return 'code=${json['code']} requestId=${json['requestId']}';
      }
    } catch (_) {}
    return 'unparseable response body';
  }

  /// Posts [token] to [uri], retrying with linear backoff on failure. Returns
  /// true if the server responded with a 2xx status. Takes [uri] explicitly,
  /// rather than resolving BASE_URL itself, so the retry/backoff behaviour is
  /// unit-testable against an injected [http.Client] independent of BASE_URL
  /// resolution.
  @visibleForTesting
  Future<bool> postToken(Uri uri, String token, {int maxRetries = 3}) async {
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await _httpClient
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(buildRegistrationBody(token)),
            )
            .timeout(const Duration(seconds: 10));

        final status = response.statusCode;
        if (status >= 200 && status < 300) {
          return true;
        }

        // RFC 9457 problem body: log only the stable code and request id.
        debugPrint(
          'Token registration failed (status $status): '
          '${_describeProblem(response.body)}',
        );

        // A 4xx other than 429 (bad request, App Check) will not succeed on
        // retry, so give up immediately.
        if (status >= 400 && status < 500 && status != 429) {
          return false;
        }
        // Rate limited (20 per 15 min per IP): back off much longer.
        if (status == 429 && attempt < maxRetries) {
          await Future.delayed(_retryDelayUnit * attempt * 5);
          continue;
        }
      } catch (e) {
        debugPrint('Token registration attempt $attempt failed: $e');
      }

      if (attempt < maxRetries) {
        await Future.delayed(_retryDelayUnit * attempt);
      }
    }
    return false;
  }
}
