import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/notifications/background_handler.dart';
import 'core/notifications/notification_service.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'app/provider_retry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Push notification setup is best-effort: Mass times, bulletins and contact
  // details don't depend on it, so a failure here must never stop runApp.
  try {
    // App-side config (BASE_URL) only; must load before NotificationService reads it.
    await dotenv.load(fileName: "assets/app.env");
  } catch (e) {
    debugPrint('Failed to load assets/app.env: $e');
  }

  // If Firebase itself fails to initialize, Crashlytics can't either — that
  // one failure mode can never be reported remotely, only via debugPrint.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase.initializeApp failed: $e');
  }

  if (firebaseReady) {
    // Local testing shouldn't pollute the real Crashlytics dashboard.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    // Reports uncaught Flutter framework errors and, below, uncaught async
    // errors outside the framework — the standard Crashlytics setup, not
    // specific to notifications.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Top-level handler, registered before runApp, so FCM can run it in the background.
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    try {
      // Attaches FCM listeners early so a tap that launched the app isn't missed.
      await NotificationService().initialize();
    } catch (e, st) {
      debugPrint('NotificationService.initialize failed: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          st,
          reason: 'NotificationService.initialize failed',
          fatal: false,
        ),
      );
    }
  }

  runApp(
    // `retry` is not optional-by-omission here: leaving it unset opts the
    // whole app into Riverpod 3.x's automatic retry. See
    // `app/provider_retry.dart` for why this app opts out.
    const ProviderScope(retry: noAutomaticRetry, child: StLukeApp()),
  );

  if (firebaseReady) {
    // Not awaited: the permission dialog and token registration (which can
    // wait on the network or, on iOS, APNs) must not delay the first frame.
    unawaited(
      NotificationService().setup().catchError((Object e, StackTrace st) {
        debugPrint('Notification setup failed: $e');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            st,
            reason: 'NotificationService.setup failed',
            fatal: false,
          ),
        );
      }),
    );
  }
}
