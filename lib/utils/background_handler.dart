import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/app_constants.dart';
import 'local_notification_handler.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');
  const AndroidNotificationDetails androidPlatformChannelChannelSpecifics =
      AndroidNotificationDetails(
    Constants.defaultNotificationChannelId,
    Constants.defaultNotificationChannelName,
    channelDescription: Constants.defaultNotificationChannelDescription,
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelChannelSpecifics);

  await localNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: message.data.toString(),
  );
}
