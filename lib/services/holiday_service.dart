import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:padmayoga/models/holiday.dart';
import '../exceptions/holiday_exception.dart';
import '../config/app_config.dart';

class HolidayService {
  final String apiUrl = Config().apiUrl;

  // Fetch holidays for a specific date range (whole month)
  Future<List<Holiday>> getHolidays(
    String accessToken,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final Map<String, String> queryParams = {};

      queryParams['startDate'] = startDate.toIso8601String();
      queryParams['endDate'] = endDate.toIso8601String();

      final Uri uri = Uri.parse('$apiUrl/api/holidays')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final holidays =
            data.map((holidayJson) => Holiday.fromJson(holidayJson)).toList();

        return holidays;
      } else {
        throw HolidayException('Failed to fetch holidays: ${response.body}');
      }
    } catch (e) {
      log('Error fetching holidays: $e');
      throw HolidayException('Error fetching holidays: $e');
    }
  }

  // Create a new holiday record
  Future<void> addHoliday(
      String accessToken, DateTime holidayDate, String reason) async {
    try {
      final String formattedDate = holidayDate.toIso8601String();

      final Map<String, dynamic> body = {
        'holidayDate': formattedDate,
        'reason': reason
      };

      final response = await http.post(
        Uri.parse('$apiUrl/api/holidays'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            body), // Send the holidayDate and reason in the request body
      );

      if (response.statusCode != 201) {
        throw HolidayException('Failed to upsert holiday: ${response.body}');
      } else {
        log('Holiday successfully upserted.');
      }
    } catch (e) {
      log('Error upserting holiday: $e');
      throw HolidayException('Error upserting holiday: $e');
    }
  }

  // Delete a holiday record by holiday date and student ID
  Future<void> deleteHoliday({
    required String accessToken,
    required DateTime holidayDate,
  }) async {
    try {
      final String formattedDate = holidayDate.toIso8601String();

      final response = await http.delete(
        Uri.parse('$apiUrl/api/holidays').replace(queryParameters: {
          'holidayDate': formattedDate,
        }),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw HolidayException('Failed to delete holiday: ${response.body}');
      } else {
        log('Holiday successfully deleted.');
      }
    } catch (e) {
      log('Error deleting holiday: $e');
      throw HolidayException('Error deleting holiday: $e');
    }
  }
}
