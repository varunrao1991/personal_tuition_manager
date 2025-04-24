import 'dart:developer';
import 'package:flutter/material.dart';
import '../../models/attendance.dart';
import '../../services/teacher/attendance_service.dart';

class AttendanceProvider with ChangeNotifier {
  AttendanceProvider(this._attendanceService);

  final AttendanceService _attendanceService;

  bool _isLoading = false;
  List<Attendance> _attendances = [];
  List<DateTime> _attendanceDatesOfStudent = [];
  DateTime? _cachedStartDate;
  DateTime? _cachedEndDate;

  List<Attendance> get attendances => _attendances;
  List<DateTime> get attendanceDatesOfStudent => _attendanceDatesOfStudent;
  bool get isLoading => _isLoading;

  void clearData() {
    _setLoading(true);
    _attendances = [];
    _attendanceDatesOfStudent = [];
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
      bool forceRefresh = false,
      bool myAttendance = false}) async {
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
      final List<Attendance> newAttendances =
          await _attendanceService.getAllAttendances(
              startDate: startDateNew,
              endDate: endDateNew);

      if (shouldResetAttendances) {
        _attendances = newAttendances;
      } else {
        _attendances.addAll(newAttendances);
      }
    });
  }

  Future<void> fetchAttendancesForStudent(
      {required DateTime startDate,
      required DateTime endDate,
      required int studentId}) async {
    await _manageAttendanceLoading(() async {
      _attendanceDatesOfStudent =
          await _attendanceService.getAttendancesForStudent(
        startDate: startDate,
        endDate: endDate,
        studentId: studentId,
      );
    });
  }

  Future<void> addAttendance(int studentId, DateTime attendanceDate) async {
    await _manageAttendanceLoading(() async {
      await _attendanceService.addAttendance(attendanceDate: attendanceDate, studentId: studentId);
      log('Attendance successfully added.');
      await fetchAttendances();
    });
  }

  Future<void> deleteAttendance(int studentId, DateTime attendanceDate) async {
    await _manageAttendanceLoading(() async {
      await _attendanceService.deleteAttendance(
            studentId: studentId,
          attendanceDate: attendanceDate);
      log('Attendance successfully deleted.');
      await fetchAttendances(
          startDate: _cachedStartDate, endDate: _cachedEndDate);
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
