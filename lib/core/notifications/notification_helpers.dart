import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_constants.dart';

/// Stateless helpers for turning an FCM [RemoteMessage] into a local
/// notification.
class NotificationHelpers {
  /// Local notification IDs must be 32-bit ints. Derived from the message ID
  /// so the same message doesn't create duplicates; falls back to the current
  /// time in seconds when FCM provides no ID.
  static int generateId(RemoteMessage message) {
    if (message.messageId != null) {
      return message.messageId.hashCode.abs();
    }
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
  /// Serialises the message data into the notification's payload so it can be
  /// recovered when the user taps it. Returns null if there is nothing to
  /// encode or the data isn't JSON-encodable.
  static String? encodePayload(Map<String, dynamic> data) {
    if (data.isEmpty) return null;
    try {
      return jsonEncode(data);
    } catch (e) {
      return null;
    }
  }
  /// Platform-specific presentation settings. The Android channel ID and sound
  /// must match the channel created in [createChannel]; on Android 8+ the
  /// channel, not these details, controls sound and importance.
  static NotificationDetails buildDetails() {
    const android = AndroidNotificationDetails(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      channelDescription: NotificationConstants.channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: NotificationConstants.androidIcon,
    );
    const iOS = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(android: android, iOS: iOS);
  }
  // Title and body prefer the FCM notification block, then fall back to the
  // data payload (data-only messages), then to a default so the notification
  // is never blank.
  static String getTitle(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'];
    return (title == null || title.isEmpty)
        ? NotificationConstants.defaultTitle
        : title.trim();
  }
  static String getBody(RemoteMessage message) {
    final body = message.notification?.body ?? message.data['body'];
    return (body == null || body.isEmpty)
        ? NotificationConstants.defaultBody
        : body.trim();
  }
  static Future<void> showNotification(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    await plugin.show(
      generateId(message),
      getTitle(message),
      getBody(message),
      buildDetails(),
      payload: encodePayload(message.data),
    );
  }
  /// Android 8+ requires a channel before any notification can be shown.
  /// Must be created once at startup (see NotificationService.initialize).
  static AndroidNotificationChannel createChannel() {
    return const AndroidNotificationChannel(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      description: NotificationConstants.channelDescription,
      importance: Importance.max,
      playSound: true,
    );
  }
  NotificationHelpers._();
}