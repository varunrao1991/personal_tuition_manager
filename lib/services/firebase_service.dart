import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/background_handler.dart';

class FirebaseService {
  FirebaseService() {
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;

  Future<bool> initialize() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('Firebase initialized with authorization.');
      return true;
    } else {
      return false;
    }
  }

  Future<void> initializeListeners(
      Function(RemoteMessage) onMessage,
      Function(RemoteMessage) onMessageOpened,
      Future<void> Function(String) onTokenRefresh) async {
    clearListeners();
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(onMessage);

    _onMessageOpenedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpened);

    _onTokenRefreshSubscription =
        _firebaseMessaging.onTokenRefresh.listen(onTokenRefresh);
  }

  Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    log('Token received: $token');
    return token;
  }

  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    log('Firebase token deleted');
  }

  Future<void> clearListeners() async {
    await _onMessageSubscription?.cancel();
    await _onMessageOpenedSubscription?.cancel();
    await _onTokenRefreshSubscription?.cancel();
    _onMessageSubscription = null;
    _onMessageOpenedSubscription = null;
    _onTokenRefreshSubscription = null;
    log('Firebase listeners cleared');
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
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
