import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import '../services/token_service.dart';
import '../utils/background_handler.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;
  final TokenService _tokenService;

  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _newNotification = false;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get newNotification => _newNotification;

  String? _firebaseToken;
  String? get firebaseToken => _firebaseToken;

  NotificationProvider(this._notificationService, this._tokenService) {
    _initialize();
  }

  Future<void> _initialize() async {
    _firebaseToken = await _notificationService.initialize(
        _onMessage, _onMessageOpened, _onTokenRefresh, backgroundHandler);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final accessToken = await _tokenService.getToken();
      await _notificationService.markNotificationAsRead(
          accessToken, notificationId);

      _notifications = _notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      notifyListeners();
      log('Notification marked as read: $notificationId');
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final accessToken = await _tokenService.getToken();
      await _notificationService.deleteNotification(
          accessToken, notificationId);

      _notifications
          .removeWhere((notification) => notification.id == notificationId);

      notifyListeners();
      log('Notification deleted: $notificationId');
    } catch (e) {
      log('Error deleting notification: $e');
    }
  }

  Future<void> fetchNotifications({
    int? page,
  }) async {
    _setLoading(true);
    _newNotification = false;
    try {
      final accessToken = await _tokenService.getToken();
      final response = await _notificationService.fetchUserNotifications(
          accessToken, page ?? _currentPage);

      if (page == 1 || page == null) {
        _notifications = response.notifications;
      } else {
        _notifications.addAll(response.notifications);
      }

      _currentPage = response.currentPage;
      _totalPages = response.totalPages;

      log('Notifications fetched for page $_currentPage: ${response.notifications.length}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetAndFetch() async {
    _currentPage = 1;
    await fetchNotifications(page: 1);
  }

  void _onMessage(RemoteMessage message) {
    _newNotification = true;
    notifyListeners();
  }

  void _onMessageOpened(RemoteMessage message) {
    if (message.notification != null) {
      _newNotification = true;
      notifyListeners();
    }
  }

  void _onTokenRefresh(String newToken) {
    _firebaseToken = newToken;
  }

  Future<void> removeToken() async {
    await _notificationService.deleteToken();
  }
}
