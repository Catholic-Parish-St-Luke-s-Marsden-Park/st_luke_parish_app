import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_helpers.dart';

/// Owns push notification setup: permissions, foreground display, tap
/// handling, and registering this device's FCM token with the backend.
/// A singleton, so listeners are only attached once per app run.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  /// Token endpoint (including `/tokens`) from BASE_URL in assets/app.env.
  /// Null, with the reason logged, if it is missing, malformed, or (in release
  /// builds) not https, so misconfiguration isn't retried as a network error.
  Uri? get _backendUri {
    final raw = dotenv.maybeGet('BASE_URL')?.trim();
    final uri = (raw == null || raw.isEmpty) ? null : Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      debugPrint('BASE_URL is missing or invalid in assets/app.env.');
      return null;
    }
    if (kReleaseMode && uri.scheme != 'https') {
      debugPrint('BASE_URL must use https in release builds.');
      return null;
    }
    return uri;
  }

  /// SharedPreferences key holding the last token the backend accepted, used
  /// to skip redundant registrations.
  static const _tokenPrefsKey = 'last_registered_fcm_token';

  final _messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;

  /// Emits the message data whenever the user taps a notification, whether it
  /// was shown by FCM (background/terminated) or locally (foreground).
  final _tapController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTap => _tapController.stream;

  StreamSubscription<String>? _tokenRefreshSub;

  /// Sets up the local notifications plugin, the Android channel and the FCM
  /// listeners. Idempotent. Does not ask for permission; see [setup].
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _plugin = FlutterLocalNotificationsPlugin();
      await _plugin!.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Permissions are requested explicitly in requestPermission(), not
          // as a side effect of initialisation.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _onTap,
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
            AndroidFlutterLocalNotificationsPlugin>()
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
    // Tap that launched the app from a terminated state.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleMessage(initial);
    // Message received while the app is open (FCM shows nothing on Android).
    FirebaseMessaging.onMessage.listen(_showForeground);
    // Tap on a notification while the app was in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
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

  void _handleMessage(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      _tapController.add(message.data);
    }
  }

  // Tap on a locally shown notification; the payload is the JSON written by
  // NotificationHelpers.encodePayload.
  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        _tapController.add(decoded);
      } else {
        debugPrint('Notification payload was not a JSON object: $payload');
      }
    } catch (e) {
      debugPrint('Failed to decode notification payload "$payload": $e');
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
    _tapController.close();
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
          await _sendTokenIfChanged(token);
        }
      }
    } catch (e) {
      debugPrint('Could not fetch FCM token: $e');
    }

    // Cancel any existing subscription first so repeated calls to
    // registerDevice() don't stack duplicate listeners.
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed.');
      _sendTokenIfChanged(newToken);
    });
  }

  /// Sends [token] to the backend only if it differs from the last
  /// successfully registered token, to avoid redundant network calls on
  /// every app launch.
  Future<void> _sendTokenIfChanged(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSent = prefs.getString(_tokenPrefsKey);
    if (lastSent == token) {
      debugPrint('FCM token unchanged, skipping registration.');
      return;
    }

    final success = await _sendTokenToServer(token);
    if (success) {
      await prefs.setString(_tokenPrefsKey, token);
    }
  }

  /// Posts [token] to the backend, retrying with linear backoff on failure.
  /// Returns true if the server responded with a 2xx status.
  Future<bool> _sendTokenToServer(
    String token, {
    int maxRetries = 3,
  }) async {
    final uri = _backendUri;
    if (uri == null) return false;

    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'fcm_token': token}),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }

        debugPrint(
          'Token registration failed (status ${response.statusCode}): '
          '${response.body}',
        );
      } catch (e) {
        debugPrint('Token registration attempt $attempt failed: $e');
      }

      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return false;
  }
}