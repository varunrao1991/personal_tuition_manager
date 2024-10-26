import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../models/attendance.dart';
import '../../utils/response_to_error.dart';

class AttendanceService {
  String apiUrl = Config().apiUrl;
  final http.Client _client;

  AttendanceService(this._client);

  Future<List<Attendance>> getAttendances(
      {required String accessToken,
      DateTime? startDate,
      DateTime? endDate}) async {
    Map<String, String> queryParams = {};

    if (startDate != null && endDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T').first;
      queryParams['endDate'] = endDate.toIso8601String().split('T').first;
    }

    Uri uri = Uri.parse('$apiUrl/api/attendances/my_attendances')
        .replace(queryParameters: queryParams);

    final response = await _client.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final attendances = (data as List)
          .map((attendanceJson) => Attendance.fromJson(attendanceJson))
          .toList();

      return attendances;
    } else {
      throw responseToError(response.body);
    }
  }
}
