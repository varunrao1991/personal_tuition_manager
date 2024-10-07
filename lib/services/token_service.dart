import 'dart:developer';

import 'package:padmayoga/utils/shared_pref.dart';
import '../exceptions/custom_exception.dart';

class TokenService {
  Future<void> saveToken(String token) async {
    await sharedPrefs.saveString('accessToken', token);
  }

  Future<String> getToken() async {
    final token = await sharedPrefs.getString('accessToken');
    if (token == null) {
      throw TokenIsNullException('No access token found in cache.');
    }
    return token;
  }

  Future<void> clearToken() async {
    await sharedPrefs.clear('accessToken');
    log("Cleared token");
  }
}
