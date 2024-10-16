import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/profile_update.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';
import '../utils/response_to_error.dart';

class LoginResponse {
  final User user;
  final String accessToken;

  LoginResponse({required this.user, required this.accessToken});
}

class AuthService {
  final String apiUrl = Config().apiUrl;
  final http.Client _client;

  AuthService(this._client);

  Future<void> requestPasswordChange(String mobile) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/auth/request-password-change'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile}),
    );

    if (response.statusCode == 200) {
      log("Password changed requested ${response.body}");
    } else {
      throw responseToError(response.body);
    }
  }

  Future<void> changePasswordWithOTP(
      String mobile, String otp, String newPassword) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/auth/change-password-with-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'mobile': mobile, 'otp': otp, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) {
      log("Password changed with OTP successfully");
    } else {
      throw responseToError(response.body);
    }
  }

  Future<LoginResponse> login(String mobile, String password) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LoginResponse(
          user: User.fromJson(data), accessToken: data['accessToken']);
    } else {
      throw responseToError(response.body);
    }
  }

  Future<User> getUserFromToken(String accessToken) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/auth/user'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw responseToError(response.body);
    }
  }

  Future<void> changePassword(
      String accessToken, String oldPassword, String newPassword) async {
    final response = await _client.post(
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

    if (response.statusCode == 200) {
      log("Password changed successfully");
    } else {
      throw responseToError(response.body);
    }
  }

  Future<User> changeProfileInfo(String accessToken, ProfileUpdate data) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/auth/change-profile-info'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      return User.fromJson(userData);
    } else {
      throw responseToError(response.body);
    }
  }
}
