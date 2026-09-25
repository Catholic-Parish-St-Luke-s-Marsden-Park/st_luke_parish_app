import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:st_luke_parish_app/firebase_options.dart';
import 'notification_helpers.dart';

/// Handles FCM messages that arrive while the app is in the background or
/// terminated. Must be a top-level function annotated with `vm:entry-point`
/// so it survives tree-shaking and can be started by the OS.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    // This runs in a separate isolate with none of the app's state, so
    // Firebase and the local notifications plugin must be set up again.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await NotificationHelpers.showNotification(message, plugin);
  } catch (e) {
    debugPrint('Background error: $e');
  }
}
