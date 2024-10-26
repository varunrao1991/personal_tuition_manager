import 'package:flutter/material.dart';
import '../../models/attendance.dart';
import '../../services/student/attendance_service.dart';
import '../../services/token_service.dart';

class AttendanceProvider with ChangeNotifier {
  AttendanceProvider(this._attendanceService, this._tokenService);

  final AttendanceService _attendanceService;
  final TokenService _tokenService;

  bool _isLoading = false;
  List<Attendance> _attendances = [];
  DateTime? _cachedStartDate;
  DateTime? _cachedEndDate;

  List<Attendance> get attendances => _attendances;
  bool get isLoading => _isLoading;

  void clearData() {
    _setLoading(true);
    _attendances = [];
    _cachedStartDate = null;
    _cachedEndDate = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchAttendances(
      {DateTime? startDate,
      DateTime? endDate,
      bool forceRefresh = false}) async {
    if (startDate == null || endDate == null) {
      return;
    }

    DateTime? startDateNew;
    DateTime? endDateNew;
    bool shouldResetAttendances = false;

    if (!forceRefresh && _cachedStartDate != null && _cachedEndDate != null) {
      if (startDate.isBefore(_cachedStartDate!) &&
          endDate.isAfter(_cachedEndDate!)) {
        startDateNew = startDate;
        endDateNew = endDate;
        shouldResetAttendances = true;
      } else if (startDate.isBefore(_cachedStartDate!)) {
        startDateNew = startDate;
        endDateNew = _cachedStartDate!.subtract(const Duration(days: 1));
      } else if (endDate.isAfter(_cachedEndDate!)) {
        startDateNew = _cachedEndDate!.add(const Duration(days: 1));
        endDateNew = endDate;
      } else {
        return;
      }
    } else {
      startDateNew = startDate;
      endDateNew = endDate;
      shouldResetAttendances = true;
    }

    if (_cachedStartDate == null || startDate.isBefore(_cachedStartDate!)) {
      _cachedStartDate = startDate;
    }
    if (_cachedEndDate == null || endDate.isAfter(_cachedEndDate!)) {
      _cachedEndDate = endDate;
    }
    await _manageAttendanceLoading(() async {
      final String accessToken = await _tokenService.getToken();
      final List<Attendance> newAttendances =
          await _attendanceService.getAttendances(
              accessToken: accessToken,
              startDate: startDateNew,
              endDate: endDateNew);

      if (shouldResetAttendances) {
        _attendances = newAttendances;
      } else {
        _attendances.addAll(newAttendances);
      }
    });
  }

  Future<void> _manageAttendanceLoading(Future<void> Function() action) async {
    _setLoading(true);
    try {
      await action();
    } finally {
      _setLoading(false);
    }
  }
}
