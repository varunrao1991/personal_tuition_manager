import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../exceptions/auth_exception.dart';
import '../models/profile_update.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';

class AuthService {
  String apiUrl = Config().apiUrl;

  Future<void> requestPasswordChange(String mobile) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/auth/request-password-change'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile}),
    );

    log(response.body); // TODO: remove once OTP through mobile is done
    if (response.statusCode != 200) {
      throw AuthException('Failed to send OTP: ${response.body}');
    }
  }

  Future<void> changePasswordWithOTP(
      String mobile, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/auth/change-password-with-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile': mobile,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw AuthException('Failed to change password: ${response.body}');
    }
  }

  Future<User?> login(String mobile, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 401) {
      throw AuthException('Unauthorized: Invalid credentials.');
    } else {
      throw AuthException('Login failed: ${response.body}');
    }
  }

  Future<User?> getUserFromToken(String accessToken) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/auth/user'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 401) {
      log('Unauthorized access: Invalid token');
      throw AuthException('Invalid token, please log in again.');
    } else {
      log(response.body);
      throw AuthException('Failed to get user from token: ${response.body}');
    }
  }

  Future<void> changePassword(
      String accessToken, String oldPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/auth/change-password'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      log('Failed to change password: ${response.body}');
      throw AuthException('Failed to change password: ${response.body}');
    } else {
      log('Password successfully changed.');
    }
  }

  Future<User> changeProfileInfo(String accessToken, ProfileUpdate data) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/auth/change-profile-info'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data.toJson()), // Use the model's toJson method
    );

    if (response.statusCode != 200) {
      log('Failed to change profile info: ${response.body}');
      throw AuthException('Failed to change profile info: ${response.body}');
    } else {
      final userData = jsonDecode(response.body);
      return User.fromJson(userData);
    }
  }
}
