import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/notification_item.dart';
import '../utils/response_to_error.dart';

class NotifyResponse {
  final List<NotificationItem> notifications;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  NotifyResponse({
    required this.notifications,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String apiUrl = Config().apiUrl;
  final http.Client _client;

  NotificationService(this._client);

  Future<String?> initialize(
    Function(RemoteMessage) onMessage,
    Function(RemoteMessage) onMessageOpened,
    Function(String) onTokenRefresh,
    Future<void> Function(RemoteMessage) backgroundHandler,
  ) async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    }

    String? token = await _firebaseMessaging.getToken();
    log('Token received in foreground: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Message received in foreground: ${message.notification?.body}');
      onMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('App opened from notification: ${message.notification?.body}');
      onMessageOpened(message);
    });

    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    _firebaseMessaging.onTokenRefresh.listen(onTokenRefresh);
    return token;
  }

  Future<void> sendTokenToBackend(
      String accessToken, String notificationToken) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/notifications/token'),
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'token': notificationToken},
    );

    if (response.statusCode != 201) {
      throw responseToError(response.body);
    }
  }

  Future<NotifyResponse> fetchUserNotifications(
      String accessToken, int page) async {
    final response = await _client.get(
      Uri.parse('$apiUrl/api/notifications?page=$page'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return NotifyResponse(
        notifications: (data['data'] as List)
            .map((notification) => NotificationItem.fromJson(notification))
            .toList(),
        totalPages: data['totalPages'],
        totalRecords: data['totalRecords'],
        currentPage: data['currentPage'],
      );
    } else {
      throw responseToError(response.body);
    }
  }

  /// Mark a notification as read by its ID.
  Future<void> markNotificationAsRead(
      String accessToken, int notificationId) async {
    final response = await _client.patch(
      Uri.parse('$apiUrl/api/notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    }
  }

  Future<void> deleteNotification(
      String accessToken, int notificationId) async {
    final response = await _client.delete(
      Uri.parse('$apiUrl/api/notifications/$notificationId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
  }

  Future<bool> checkNotificationPermission() async {
    NotificationSettings settings =
        await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<bool> enableNotifications() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
