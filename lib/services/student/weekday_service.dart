import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../utils/response_to_error.dart';

class WeekdayService {
  String apiUrl = Config().apiUrl;
  final http.Client _client;

  WeekdayService(this._client);

  Future<List<int>> getWeekdays(String accessToken) async {
    final response = await _client.get(
      Uri.parse('$apiUrl/api/weekdays/student'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<int> weekdays = List<int>.from(data);
      return weekdays;
    } else {
      throw responseToError(response.body);
    }
  }
}
