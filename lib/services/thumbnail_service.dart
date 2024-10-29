import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/response_to_error.dart';

class ThumbnailService {
  final String apiUrl = Config().apiUrl;
  final http.Client _client;

  ThumbnailService(this._client);

  Future<Uint8List> fetchProfileThumbnail(
      String accessToken, int userId) async {
    final response = await _client.get(
      Uri.parse('$apiUrl/api/profile/thumbnail/$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw responseToError(response.body);
    }
  }
}
