import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  bool _isLoading = false;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> initialize() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> doesPinExist() async {
    return await _authService.doesPinExist();
  }

  Future<bool> login(String pin) async {
    _setLoading(true);
    try {
      final isValid = await _authService.verifyPin(pin);
      if (isValid) {
        await _authService.login();
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String pin, String question, String answer) async {
    _setLoading(true);
    try {
      await _authService.setPin(pin, question, answer);
      await _authService.login();
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePin(String newPin) async {
    _setLoading(true);
    try {
      await _authService.changePin(newPin);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, String>> getSecurityQuestions() async {
    return await _authService.getSecurityQuestions();
  }

  Future<bool> verifySecurityQuestionAnswer(String question, String answer) async {
    return (await _authService.verifySecurityQuestion(question) && await _authService.verifySecurityAnswer(answer));
  }

  Future<bool> hasSecurityQuestions() async {
    return await _authService.hasSecurityQuestions();
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _isLoggedIn = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void clearData() {
    _setLoading(true);
    _isLoggedIn = false;
    _setLoading(false);
  }
}
