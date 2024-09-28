import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:padmayoga/models/profile_update.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import '../exceptions/auth_exception.dart'; // Import your custom exception

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final AuthService _authService;
  final TokenService _tokenService;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isTemporaryPassword => _user?.isTemporaryPassword ?? false;

  // Constructor to inject AuthService and TokenService
  AuthProvider(this._authService, this._tokenService);

  // Refresh function to load user details from the token
  Future<void> refresh() async {
    try {
      final String? accessToken = await _tokenService.getToken();

      if (accessToken != null) {
        if (_user == null) {
          _user = await _authService.getUserFromToken(accessToken);

          if (_user == null) {
            log('Invalid token: clearing token.');
            await _tokenService.clearToken();
            throw AuthException('Invalid token, please log in again.');
          } else {
            log('User successfully fetched from token.');
            notifyListeners();
          }
        }
      }
    } catch (e) {
      log('Error during refresh: $e');
      rethrow; // Propagate the exception to be handled by the caller
    }
  }

  // Login operation
  Future<void> login(String mobile, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _authService.login(mobile, password);
      if (userData != null && userData.accessToken != null) {
        _user = userData;
        await _tokenService.saveToken(userData.accessToken!);
        log("Saved access token");
      } else {
        throw AuthException('Login failed: Invalid user or access token.');
      }
    } on AuthException catch (e) {
      log('Login error: $e');
      rethrow; // Propagate AuthException specifically
    } catch (e) {
      log('Unknown login error: $e');
      rethrow; // Propagate any other exceptions
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request password change
  Future<void> requestPasswordChange(String mobile) async {
    try {
      await _authService.requestPasswordChange(mobile);
    } on AuthException catch (e) {
      log('Password change request error: $e');
      rethrow; // Re-propagate to the UI
    }
  }

  // Change password with OTP
  Future<void> changePasswordWithOTP(
      String mobile, String otp, String newPassword) async {
    try {
      await _authService.changePasswordWithOTP(mobile, otp, newPassword);
    } on AuthException catch (e) {
      log('Change password with OTP error: $e');
      rethrow;
    }
  }

  // Change password (requires access token)
  Future<void> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _tokenService.getToken();
      if (accessToken != null) {
        await _authService.changePassword(
            accessToken, oldPassword, newPassword);
        _user!.isTemporaryPassword = false; // Mark as password changed
      } else {
        throw AuthException('No access token found.');
      }
    } on AuthException catch (e) {
      log('Change password error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change profile info (requires access token)
  Future<void> changeProfileInfo(ProfileUpdate profile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _tokenService.getToken();
      if (accessToken != null) {
        var userData =
            await _authService.changeProfileInfo(accessToken, profile);
        _user = User.copyFrom(userData);
        _user!.isTemporaryPassword = false; // Mark as password changed
      } else {
        throw AuthException('No access token found.');
      }
    } on AuthException catch (e) {
      log('Update profile error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout operation
  Future<void> logout() async {
    try {
      await _tokenService.clearToken(); // Clear token on logout
      _user = null;
    } catch (e) {
      log('Logout error: $e');
      throw AuthException('Error during logout.');
    }
    notifyListeners();
  }
}
