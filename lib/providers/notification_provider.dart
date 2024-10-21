import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import '../services/token_service.dart';

class NotificationProvider with ChangeNotifier {
  NotificationProvider(this._notificationService, this._tokenService);

  final NotificationService _notificationService;
  final TokenService _tokenService;

  bool _isLoading = false;
  List<NotificationItem> _notifications = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _unread = false;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  void clearData() {
    _setLoading(true);
    _currentPage = 1;
    _totalPages = 1;
    _notifications = [];
    _unread = false;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> markNotificationAsRead(List<String> ids) async {
    try {
      final accessToken = await _tokenService.getToken();
      await _notificationService.markNotificationAsRead(accessToken, ids);

      await fetchNotifications(unread: _unread);
      notifyListeners();
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotifications(List<String> ids) async {
    try {
      final accessToken = await _tokenService.getToken();
      await _notificationService.deleteNotifications(accessToken, ids);
      await fetchNotifications(unread: _unread);
      notifyListeners();
    } catch (e) {
      log('Error deleting notification: $e');
    }
  }

  Future<void> fetchNotifications({
    int? page,
    required bool unread,
  }) async {
    _setLoading(true);
    try {
      final accessToken = await _tokenService.getToken();
      final response = await _notificationService.fetchUserNotifications(
          accessToken, page ?? _currentPage, unread);

      if (page == 1 || page == null) {
        _notifications = response.notifications;
      } else {
        _notifications.addAll(response.notifications);
      }

      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      _unread = unread;

      log('Notifications fetched for page $_currentPage: ${response.notifications.length}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetAndFetch() async {
    _currentPage = 1;
    await fetchNotifications(page: 1, unread: _unread);
  }
}
