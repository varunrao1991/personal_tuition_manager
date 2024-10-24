import 'dart:developer';
import 'package:flutter/material.dart';
import '../exceptions/custom_exception.dart';
import '../models/profile_update.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider(this._authService, this._tokenService);

  final AuthService _authService;
  final TokenService _tokenService;

  bool _isLoading = false;
  User? _user;
  bool _newNotification = false;
  bool _onMessageOpenedStatus = false;

  bool get newNotification => _newNotification;
  bool get onMessageOpenedStatus => _onMessageOpenedStatus;
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isTemporaryPassword => _user?.isTemporaryPassword ?? false;

  void clearData() {
    _setLoading(true);
    _user = null;
    _newNotification = false;
    _onMessageOpenedStatus = false;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void resetNotification() {
    _newNotification = false;
    _onMessageOpenedStatus = false;
    notifyListeners();
  }

  Future<void> loadUser() async {
    _setLoading(true);
    try {
      final accessToken = await _tokenService.getToken();
      final user = await _authService.getUserFromToken(accessToken);
      _user = user;
    } catch (e) {
      _user = null;
      if (e is InvalidTokenException || e is InvalidSessionException) {
        await _tokenService.clearToken();
      } else if (e is TokenIsNullException) {
        log("Token is null");
      } else {
        log("Failed to load user: $e");
        rethrow;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String mobile, String password) async {
    _setLoading(true);
    try {
      await _authService.register(name, mobile, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String mobile, String password) async {
    _setLoading(true);
    try {
      final userData = await _authService.login(mobile, password);
      _user = userData.user;
      await _tokenService.saveToken(userData.accessToken);
      log("Saved access token");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> requestPasswordChange(String mobile) async {
    _setLoading(true);
    try {
      await _authService.requestPasswordChange(mobile);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePasswordWithOTP(
      String mobile, String otp, String newPassword) async {
    _setLoading(true);
    try {
      await _authService.changePasswordWithOTP(mobile, otp, newPassword);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    try {
      final accessToken = await _tokenService.getToken();
      final accessTokenNew = await _authService.changePassword(
          accessToken, oldPassword, newPassword);
      await _tokenService.saveToken(accessTokenNew);
      _user?.isTemporaryPassword = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeProfileInfo(ProfileUpdate profile) async {
    _setLoading(true);
    try {
      final accessToken = await _tokenService.getToken();
      final userData =
          await _authService.changeProfileInfo(accessToken, profile);
      _user = User.copyFrom(userData);
      _user?.isTemporaryPassword = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    final accessToken = await _tokenService.getToken();

    await Future.wait([
      _authService.logout(accessToken),
      _tokenService.clearToken(),
    ]);

    _setLoading(false);
  }
}
