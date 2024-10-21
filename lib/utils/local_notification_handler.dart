import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes/navigator.dart';

// Create a global instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Initialize the notification plugin
Future<void> initializeLocalNotifications() async {
  // Android-specific settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS-specific settings
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );

  // Combined initialization settings for both Android and iOS
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Initialize the local notifications plugin
  await localNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse:
        _onDidReceiveBackgroundNotificationResponse,
  );
}

// Handle notification taps in the foreground
void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  log('Notification tapped: ${notificationResponse.payload}');
  if (notificationResponse.payload != null) {
    navigateToScreen(notificationResponse.payload!);
  }
}

// Handle background notification taps (optional for Android/iOS behavior)
void _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse notificationResponse) async {
  log('Background notification tapped: ${notificationResponse.payload}');
  if (notificationResponse.payload != null) {
    navigateToScreen(notificationResponse.payload!);
  }
}

// Handle notifications received while the app is in the foreground (iOS only)
Future<void> onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  log('Local Notification: id=$id, title=$title, body=$body, payload=$payload');
  if (payload != null) {
    navigateToScreen(payload);
  }
}

// Navigate to the specified screen based on the notification payload
void navigateToScreen(String payload) {
  switch (payload) {
    default:
      navigatorKey.currentState?.pushNamed('/notification');
      break;
  }
}
