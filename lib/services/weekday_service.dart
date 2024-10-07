import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../exceptions/weekday_exception.dart';
import '../config/app_config.dart';
import '../utils/response_to_error.dart';

class WeekdayService {
  String apiUrl = Config().apiUrl;
  final http.Client _client;

  WeekdayService(this._client);

  Future<void> setWeekdays(String accessToken, List<int> days) async {
    // Ensure the days are valid integers between 0 and 6
    if (days.any((day) => day < 0 || day > 6)) {
      throw WeekdayException(
          'Days must be integers between 0 (Sunday) and 6 (Saturday).');
    }

    // Convert the list of days to a JSON-encoded string
    String daysBody = jsonEncode({'days': days});

    final response = await _client.post(
      Uri.parse('$apiUrl/api/weekdays'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: daysBody,
    );

    if (response.statusCode != 201) {
      throw responseToError(response.body);
    } else {
      log('Weekdays successfully set.');
    }
  }

  // Get weekdays for a user
  Future<List<int>> getWeekdays(String accessToken) async {
    final response = await _client.get(
      Uri.parse(
          '$apiUrl/api/weekdays'), // Get weekdays without additional parameters
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<int> weekdays =
          List<int>.from(data); // Directly assuming response is a list of days
      return weekdays;
    } else {
      throw responseToError(response.body);
    }
  }
}
