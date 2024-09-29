import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/weekday_service.dart';
import '../services/token_service.dart';
import '../exceptions/weekday_exception.dart';

class WeekdayProvider with ChangeNotifier {
  List<int> _weekdays = []; // List to hold cached weekdays
  bool _isLoading = false;
  final WeekdayService _weekdayService;
  final TokenService _tokenService;

  // Getters
  List<int> get weekdays => _weekdays;
  bool get isLoading => _isLoading;

  WeekdayProvider(this._weekdayService, this._tokenService);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch weekdays for a user
  Future<void> fetchWeekdays() async {
    // If weekdays are already cached, return early
    if (_weekdays.isNotEmpty) return;

    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken == null) {
        throw WeekdayException('No access token found.');
      }

      _weekdays = await _weekdayService.getWeekdays(accessToken);
      log('Weekdays successfully fetched: $_weekdays');
    } catch (e) {
      log('Fetch weekdays error: $e');
      throw WeekdayException('Failed to fetch weekdays: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set weekdays for a user
  Future<void> setWeekdays(List<int> days) async {
    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken == null) {
        throw WeekdayException('No access token found.');
      }

      await _weekdayService.setWeekdays(accessToken, days);
      _weekdays = days; // Update the cached weekdays
      log('Weekdays successfully set: $_weekdays');
    } catch (e) {
      log('Set weekdays error: $e');
      throw WeekdayException('Failed to set weekdays: $e');
    } finally {
      _setLoading(false);
    }
  }
}
