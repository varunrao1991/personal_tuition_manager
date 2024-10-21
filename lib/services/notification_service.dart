import 'dart:convert';
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
  final String apiUrl = Config().apiUrl;
  final http.Client _client;

  NotificationService(this._client);

  Future<NotifyResponse> fetchUserNotifications(
      String accessToken, int page, bool unread) async {
    final queryParameters = {
      'page': page.toString(),
      'unread': unread.toString(),
    };

    final uri = Uri.parse('$apiUrl/api/notifications')
        .replace(queryParameters: queryParameters);

    final response = await _client.get(
      uri,
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

  Future<void> markNotificationAsRead(
      String accessToken, List<String> ids) async {
    final response = await _client.patch(
      Uri.parse('$apiUrl/api/notifications/read'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'ids': ids}),
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    }
  }

  Future<void> deleteNotifications(String accessToken, List<String> ids) async {
    final response = await _client.delete(
      Uri.parse('$apiUrl/api/notifications'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'ids': ids}),
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    }
  }
}
