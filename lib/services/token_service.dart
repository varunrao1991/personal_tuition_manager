// TokenService.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }
}