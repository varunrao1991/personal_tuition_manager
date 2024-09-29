import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../services/token_service.dart';
import '../exceptions/attendance_exception.dart';

class AttendanceProvider with ChangeNotifier {
  List<Attendance> _attendances = [];
  bool _isLoading = false;
  final AttendanceService _attendanceService;
  final TokenService _tokenService;

  // Cached parameters
  DateTime? _cachedStartDate;
  DateTime? _cachedEndDate;

  // Getters
  List<Attendance> get attendances => _attendances;
  bool get isLoading => _isLoading;

  AttendanceProvider(this._attendanceService, this._tokenService);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch attendances for a given date range (whole month)
  Future<void> fetchAttendances({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _cachedStartDate = startDate ?? _cachedStartDate;
    _cachedEndDate = endDate ?? _cachedEndDate;

    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken == null) {
        throw AttendanceException('No access token found.');
      }

      _attendances = await _attendanceService.getAttendances(
        accessToken: accessToken,
        startDate: _cachedStartDate,
        endDate: _cachedEndDate,
      );
      log('Attendances successfully fetched.');
    } catch (e) {
      log('Fetch attendances error: $e');
      throw AttendanceException('Failed to fetch attendances: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add attendance
  Future<void> addAttendance(int studentId, DateTime attendanceDate) async {
    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken == null) {
        throw AttendanceException('No access token found.');
      }

      await _attendanceService.addAttendance(
          accessToken, attendanceDate, studentId);
      log('Attendance successfully added.');
      await fetchAttendances(); // Optionally refresh the list after adding
    } catch (e) {
      log('Add attendance error: $e');
      throw AttendanceException('Failed to add attendance: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete attendance
  Future<void> deleteAttendance(int studentId, DateTime attendanceDate) async {
    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken == null) {
        throw AttendanceException('No access token found.');
      }

      await _attendanceService.deleteAttendance(
          accessToken: accessToken,
          studentId: studentId,
          attendanceDate: attendanceDate);
      log('Attendance successfully deleted.');
      await fetchAttendances(
          startDate: _cachedStartDate, endDate: _cachedEndDate);
    } catch (e) {
      log('Delete attendance error: $e');
      throw AttendanceException('Failed to delete attendance: $e');
    } finally {
      _setLoading(false);
    }
  }
}
