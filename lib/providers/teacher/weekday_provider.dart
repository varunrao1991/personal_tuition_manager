import 'dart:developer';
import 'package:flutter/material.dart';
import '../../services/teacher/weekday_service.dart';

class WeekdayProvider with ChangeNotifier {
  WeekdayProvider(this._weekdayService);

  final WeekdayService _weekdayService;

  bool _isLoading = false;
  List<int> _weekdays = [];

  List<int> get weekdays => _weekdays;
  bool get isLoading => _isLoading;

  void clearData() {
    _setLoading(true);
    _weekdays = [];
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchWeekdays() async {
    if (_weekdays.isNotEmpty) return;

    _setLoading(true);
    try {
      _weekdays = await _weekdayService.getWeekdays();
      log('Weekdays successfully fetched: $_weekdays');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setWeekdays(List<int> days) async {
    _setLoading(true);
    try {
      await _weekdayService.setWeekdays(days);
      _weekdays = days;
      log('Weekdays successfully set: $_weekdays');
    } finally {
      _setLoading(false);
    }
  }
}
