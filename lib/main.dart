import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/notifications/background_handler.dart';
import 'core/notifications/notification_service.dart';
import 'firebase_options.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // App-side config (BASE_URL) only; must load before NotificationService reads it.
  await dotenv.load(fileName: "assets/app.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Top-level handler, registered before runApp, so FCM can run it in the background.
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  // Attaches FCM listeners early so a tap that launched the app isn't missed.
  await NotificationService().initialize();
  runApp(const ProviderScope(child: StLukeApp()));
  // Not awaited: the permission dialog and token registration (which can wait
  // on the network or, on iOS, APNs) must not delay the first frame.
  unawaited(
    NotificationService().setup().catchError((Object e) {
      debugPrint('Notification setup failed: $e');
    }),
  );
}