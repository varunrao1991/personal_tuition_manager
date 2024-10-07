import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/holiday.dart';
import '../services/holiday_service.dart';
import '../services/token_service.dart';

class HolidayProvider with ChangeNotifier {
  List<Holiday> _holidays = [];
  bool _isLoading = false;
  final HolidayService _holidayService;
  final TokenService _tokenService;

  DateTime? _cachedStartDate;
  DateTime? _cachedEndDate;

  List<Holiday> get holidays => _holidays;
  bool get isLoading => _isLoading;

  HolidayProvider(this._holidayService, this._tokenService);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchHolidays({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _cachedStartDate = startDate ?? _cachedStartDate;
    _cachedEndDate = endDate ?? _cachedEndDate;

    try {
      final String accessToken = await _tokenService.getToken();
      _holidays = await _holidayService.getHolidays(
        accessToken,
        _cachedStartDate!,
        _cachedEndDate!,
      );
      log('Holidays successfully fetched.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addHoliday(DateTime holidayDate, String reason) async {
    _setLoading(true);
    try {
      final String accessToken = await _tokenService.getToken();
      await _holidayService.addHoliday(accessToken, holidayDate, reason);
      log('Holiday successfully added.');
      await fetchHolidays(); // Refresh the list after adding
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHoliday(DateTime holidayDate) async {
    _setLoading(true);
    try {
      final String accessToken = await _tokenService.getToken();
      await _holidayService.deleteHoliday(
          accessToken: accessToken, holidayDate: holidayDate);
      log('Holiday successfully deleted.');
      await fetchHolidays(
          startDate: _cachedStartDate,
          endDate: _cachedEndDate); // Refresh the list after deletion
    } finally {
      _setLoading(false);
    }
  }
}
