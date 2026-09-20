class NotificationConstants {

  static const String channelId = 'app_channel';
  static const String channelName = 'Notifications';
  static const String channelDescription = 'App notifications';
  
  static const String defaultTitle = 'New Notification';
  static const String defaultBody = 'You have a notification';
  
  static const String androidIcon = '@mipmap/ic_launcher';
  // Android raw resource name: file in res/raw, referenced without extension.
  static const String androidSound = 'notification_sound';
  // iOS needs the full file name, and the file must be bundled in the Runner
  // target; if it is missing iOS falls back to the default sound.
  static const String iosSound = 'notification_sound.aiff';
  NotificationConstants._();
}