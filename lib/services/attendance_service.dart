import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../exceptions/attendance_exception.dart';
import '../models/attendance.dart';
import '../models/create_attendance.dart';
import '../config/app_config.dart';

class AttendanceService {
  String apiUrl = Config().apiUrl;

  // Fetch attendances for a specific date range (whole month)
  Future<List<Attendance>> getAttendances({
    required String accessToken,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Map<String, String> queryParams = {};

      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
        queryParams['endDate'] = endDate.toIso8601String();
      }

      Uri uri = Uri.parse('$apiUrl/api/attendances')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: {
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
        throw AttendanceException(
            'Failed to fetch attendances: ${response.body}');
      }
    } catch (e) {
      log('Error fetching attendances: $e');
      throw AttendanceException('Error fetching attendances: $e');
    }
  }

  // Create a new attendance record
  Future<void> addAttendance(
      String accessToken, DateTime attendanceDate, int studentId) async {
    try {
      String formattedDate = attendanceDate.toIso8601String();

      final response = await http.post(
        Uri.parse(
            '$apiUrl/api/attendances?studentId=$studentId&attendanceDate=$formattedDate'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode != 201) {
        throw AttendanceException('Failed to add attendance: ${response.body}');
      } else {
        log('Attendance successfully created.');
      }
    } catch (e) {
      log('Error creating attendance: $e');
      throw AttendanceException('Error creating attendance: $e');
    }
  }

  // Delete an attendance record by ID
  Future<void> deleteAttendance({
    required String accessToken,
    required int studentId,
    required DateTime attendanceDate,
  }) async {
    try {
      String formattedDate = attendanceDate.toIso8601String();

      final response = await http.delete(
        Uri.parse(
            '$apiUrl/api/attendances?studentId=$studentId&attendanceDate=$formattedDate'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw AttendanceException(
            'Failed to delete attendance: ${response.body}');
      } else {
        log('Attendance successfully deleted.');
      }
    } catch (e) {
      log('Error deleting attendance: $e');
      throw AttendanceException('Error deleting attendance: $e');
    }
  }
}
