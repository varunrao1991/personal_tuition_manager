import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
  final String userType;

  AuthService(this._client, this.userType);

  Future<void> requestPasswordChange(String mobile) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/auth/$userType/request-password-change'),
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
      Uri.parse('$apiUrl/api/auth/$userType/change-password-with-otp'),
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

  Future<void> logout(String accessToken) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/auth/logout'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    }
  }

  Future<void> register(String name, String mobile, String password) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'mobile': mobile, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log("Register: $data");
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

  Future<String> changePassword(
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
      final data = jsonDecode(response.body);
      log("Password changed successfully");
      return data['accessToken'];
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

  Future<void> uploadProfilePicture(String accessToken, Uint8List imageData,
      String extension, String mimeType) async {
    final uri = Uri.parse('$apiUrl/api/profile/upload');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.headers['Content-Type'] = 'multipart/form-data';

    String filename = 'profile_picture$extension';

    request.files.add(
      http.MultipartFile.fromBytes(
        'largeImage',
        imageData,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
    } else {
      final responseBody =
          await response.stream.bytesToString(); // Read response body
      final errorMessage = jsonDecode(responseBody); // Decode if JSON
      log('Error: ${errorMessage['error']}'); // Adjust based on your API's response structure
      responseToError(errorMessage);
    }
  }

  Future<http.Response> fetchMyProfileThumbnail(String accessToken) async {
    final response = await _client.get(
      Uri.parse('$apiUrl/api/profile/my_thumbnail'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw responseToError(response.body);
    }
  }

  Future<http.Response> fetchMyProfileLargeImage(String accessToken) async {
    final response = await _client.get(
      Uri.parse('$apiUrl/api/profile/my_large'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw responseToError(response.body);
    }
  }
}
