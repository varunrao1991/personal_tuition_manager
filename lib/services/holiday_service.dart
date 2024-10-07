import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:padmayoga/models/holiday.dart';
import '../config/app_config.dart';
import '../utils/response_to_error.dart';

class HolidayService {
  final String apiUrl = Config().apiUrl;
  final http.Client _client;

  HolidayService(this._client);

  Future<List<Holiday>> getHolidays(
    String accessToken,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final Map<String, String> queryParams = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };

    final Uri uri =
        Uri.parse('$apiUrl/api/holidays').replace(queryParameters: queryParams);

    final response = await _client.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      final holidays =
          data.map((holidayJson) => Holiday.fromJson(holidayJson)).toList();
      return holidays;
    } else {
      throw responseToError(response.body);
    }
  }

  Future<void> addHoliday(
      String accessToken, DateTime holidayDate, String reason) async {
    final String formattedDate = holidayDate.toIso8601String();

    final Map<String, dynamic> body = {
      'holidayDate': formattedDate,
      'reason': reason
    };

    final response = await _client.post(
      Uri.parse('$apiUrl/api/holidays'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw responseToError(response.body);
    } else {
      log('Holiday successfully upserted.');
    }
  }

  Future<void> deleteHoliday({
    required String accessToken,
    required DateTime holidayDate,
  }) async {
    final String formattedDate = holidayDate.toIso8601String();

    final response = await _client.delete(
      Uri.parse('$apiUrl/api/holidays').replace(queryParameters: {
        'holidayDate': formattedDate,
      }),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log('Holiday successfully deleted.');
    }
  }
}
