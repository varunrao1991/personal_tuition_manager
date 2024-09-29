import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../exceptions/weekday_exception.dart'; // Custom exception for weekday service
import '../config/app_config.dart'; // Configuration for API URL

class WeekdayService {
  String apiUrl = Config().apiUrl;

  // Set weekdays for a user
  Future<void> setWeekdays(String accessToken, List<int> days) async {
    try {
      // Ensure the days are valid integers between 0 and 6
      if (days.any((day) => day < 0 || day > 6)) {
        throw WeekdayException(
            'Days must be integers between 0 (Sunday) and 6 (Saturday).');
      }

      // Convert the list of days to a comma-separated string
      String daysQuery = jsonEncode(days);

      final response = await http.post(
        Uri.parse(
            '$apiUrl/api/weekdays?days=$daysQuery'), // Add days as query parameters
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 201) {
        throw WeekdayException('Failed to set weekdays: ${response.body}');
      } else {
        log('Weekdays successfully set.');
      }
    } catch (e) {
      log('Error setting weekdays: $e');
      throw WeekdayException('Error setting weekdays: $e');
    }
  }

  // Get weekdays for a user
  Future<List<int>> getWeekdays(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$apiUrl/api/weekdays'), // Get weekdays without additional parameters
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<int> weekdays = List<int>.from(
            data); // Directly assuming response is a list of days
        return weekdays;
      } else {
        throw WeekdayException('Failed to fetch weekdays: ${response.body}');
      }
    } catch (e) {
      log('Error fetching weekdays: $e');
      throw WeekdayException('Error fetching weekdays: $e');
    }
  }
}
