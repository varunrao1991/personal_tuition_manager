import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/holiday.dart';
import '../services/holiday_service.dart';
import '../services/token_service.dart';
import '../exceptions/holiday_exception.dart';

class HolidayProvider with ChangeNotifier {
  List<Holiday> _holidays = [];
  bool _isLoading = false;
  final HolidayService _holidayService;
  final TokenService _tokenService;

  // Cached parameters
  DateTime? _cachedStartDate;
  DateTime? _cachedEndDate;

  // Getters
  List<Holiday> get holidays => _holidays;
  bool get isLoading => _isLoading;

  HolidayProvider(this._holidayService, this._tokenService);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch holidays for a given date range (whole month)
  Future<void> fetchHolidays({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _cachedStartDate = startDate ?? _cachedStartDate;
    _cachedEndDate = endDate ?? _cachedEndDate;

    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken == null) {
        throw HolidayException('No access token found.');
      }

      _holidays = await _holidayService.getHolidays(
        accessToken,
        _cachedStartDate!,
        _cachedEndDate!,
      );
      log('Holidays successfully fetched.');
    } catch (e) {
      log('Fetch holidays error: $e');
      throw HolidayException('Failed to fetch holidays: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add holiday
  Future<void> addHoliday(DateTime holidayDate, String reason) async {
    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken == null) {
        throw HolidayException('No access token found.');
      }

      await _holidayService.addHoliday(accessToken, holidayDate, reason);
      log('Holiday successfully added.');
      await fetchHolidays(); // Optionally refresh the list after adding
    } catch (e) {
      log('Add holiday error: $e');
      throw HolidayException('Failed to add holiday: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete holiday
  Future<void> deleteHoliday(DateTime holidayDate) async {
    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken == null) {
        throw HolidayException('No access token found.');
      }

      await _holidayService.deleteHoliday(
          accessToken: accessToken, holidayDate: holidayDate);
      log('Holiday successfully deleted.');
      await fetchHolidays(startDate: _cachedStartDate, endDate: _cachedEndDate);
    } catch (e) {
      log('Delete holiday error: $e');
      throw HolidayException('Failed to delete holiday: $e');
    } finally {
      _setLoading(false);
    }
  }
}
