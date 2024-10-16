import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/attendance.dart';
import '../config/app_config.dart';
import '../utils/response_to_error.dart';

class AttendanceService {
  String apiUrl = Config().apiUrl;
  final http.Client _client;

  AttendanceService(this._client);

  Future<List<Attendance>> getAttendances({
    required String accessToken,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Map<String, String> queryParams = {};

    if (startDate != null && endDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
      queryParams['endDate'] = endDate.toIso8601String();
    }

    Uri uri = Uri.parse('$apiUrl/api/attendances')
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

  Future<List<DateTime>> getAttendancesForStudent({
    required String accessToken,
    required int studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    Map<String, String> queryParams = {};

    queryParams['studentId'] = studentId.toString();
    queryParams['startDate'] = startDate.toIso8601String();
    queryParams['endDate'] = endDate.toIso8601String();

    Uri uri = Uri.parse('$apiUrl/api/attendances/attendances_for_student')
        .replace(queryParameters: queryParams);

    final response = await _client.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final attendances = (data as List)
          .map((attendanceJson) =>
              DateTime.parse(attendanceJson['attendanceDate']))
          .toList();

      return attendances;
    } else {
      throw responseToError(response.body);
    }
  }

  Future<void> addAttendance(
      String accessToken, DateTime attendanceDate, int studentId) async {
    String formattedDate = attendanceDate.toIso8601String();

    final response = await _client.post(
      Uri.parse(
          '$apiUrl/api/attendances?studentId=$studentId&attendanceDate=$formattedDate'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 201) {
      throw responseToError(response.body);
    } else {
      log('Attendance successfully created.');
    }
  }

  Future<void> deleteAttendance({
    required String accessToken,
    required int studentId,
    required DateTime attendanceDate,
  }) async {
    String formattedDate = attendanceDate.toIso8601String();

    final response = await _client.delete(
      Uri.parse(
          '$apiUrl/api/attendances?studentId=$studentId&attendanceDate=$formattedDate'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log('Attendance successfully deleted.');
    }
  }
}
