import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:padmayoga/exceptions/custom_exception.dart';
import 'package:padmayoga/models/profile_update.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final AuthService _authService;
  final TokenService _tokenService;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isTemporaryPassword => _user?.isTemporaryPassword ?? false;

  AuthProvider(this._authService, this._tokenService);

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _tokenService.getToken();
      final user = await _authService.getUserFromToken(accessToken);
      _user = user;
    } catch (e) {
      _user = null;
      if (e is InvalidTokenException) {
        await _tokenService.clearToken();
      } else if (e is TokenIsNullException) {
        log("Token is null");
      } else {
        rethrow;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String mobile, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _authService.login(mobile, password);
      _user = userData.user;
      await _tokenService.saveToken(userData.accessToken);
      log("Saved access token");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestPasswordChange(String mobile) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.requestPasswordChange(mobile);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePasswordWithOTP(
      String mobile, String otp, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.changePasswordWithOTP(mobile, otp, newPassword);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _tokenService.getToken();
      await _authService.changePassword(accessToken, oldPassword, newPassword);
      _user!.isTemporaryPassword = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeProfileInfo(ProfileUpdate profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _tokenService.getToken();
      var userData = await _authService.changeProfileInfo(accessToken, profile);
      _user = User.copyFrom(userData);
      _user!.isTemporaryPassword = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    _user = null;
    await _tokenService.clearToken();

    _isLoading = false;
    notifyListeners();
  }
}
