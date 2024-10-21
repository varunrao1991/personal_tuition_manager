import 'dart:developer';
import 'package:flutter/material.dart';
import '../exceptions/holiday_exception.dart';
import '../models/holiday.dart';
import '../services/holiday_service.dart';
import '../services/token_service.dart';

class HolidayProvider with ChangeNotifier {
  HolidayProvider(this._holidayService, this._tokenService);

  final HolidayService _holidayService;
  final TokenService _tokenService;

  bool _isLoading = false;
  List<Holiday> _holidays = [];
  DateTime? _cachedStartDate;
  DateTime? _cachedEndDate;

  List<Holiday> get holidays => _holidays;
  bool get isLoading => _isLoading;

  void clearData() {
    _setLoading(true);
    _cachedEndDate = null;
    _cachedStartDate = null;
    _holidays = [];
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchHolidays({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);

    final newStartDate = startDate ?? _cachedStartDate;
    final newEndDate = endDate ?? _cachedEndDate;
    if (newStartDate == null || newEndDate == null) {
      throw HolidayException(
          "Either of the requested dates and cacthed dates are null to fetch");
    }

    try {
      final String accessToken = await _tokenService.getToken();
      _holidays = await _holidayService.getHolidays(
        accessToken,
        newStartDate,
        newEndDate,
      );
      _cachedStartDate = newStartDate;
      _cachedEndDate = newEndDate;
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
      await fetchHolidays();
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
      await fetchHolidays();
    } finally {
      _setLoading(false);
    }
  }
}
