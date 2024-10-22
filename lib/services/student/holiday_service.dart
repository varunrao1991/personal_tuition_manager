import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../models/holiday.dart';
import '../../utils/response_to_error.dart';

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
        Uri.parse('$apiUrl/api/holidays/student').replace(queryParameters: queryParams);

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
}
