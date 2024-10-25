import 'dart:developer';

import 'package:flutter/material.dart';
import '../../models/teacher/student_model.dart';
import '../../models/teacher/student_update.dart';
import '../../services/teacher/student_service.dart';
import '../../services/token_service.dart';

class StudentProvider with ChangeNotifier {
  StudentProvider(this._studentService, this._tokenService);

  final StudentService _studentService;
  final TokenService _tokenService;

  bool _isLoading = false;
  List<Student> _students = [];
  int _currentPage = 1;
  int _totalPages = 1;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  void clearData() {
    _setLoading(true);
    _students = [];
    _currentPage = 1;
    _totalPages = 1;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchStudents({
    int? page,
    String? sort,
    String? order,
    String? name,
  }) async {
    _setLoading(true);

    try {
      final accessToken = await _tokenService.getToken();
      final response = await _studentService.getStudents(
        accessToken: accessToken,
        page: page ?? _currentPage,
        sort: sort,
        order: order,
        name: name,
      );

      if (page == 1 || page == null) {
        _students = response.students;
      } else {
        _students.addAll(response.students);
      }

      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      log('Students successfully fetched for $_currentPage: ${response.students.length}.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetAndFetch({
    String? sort,
    String? order,
    String? name,
  }) async {
    _currentPage = 1;
    await fetchStudents(page: 1, sort: sort, order: order, name: name);
  }

  Future<void> createStudent(StudentUpdate studentUpdate) async {
    _setLoading(true);

    try {
      final accessToken = await _tokenService.getToken();
      await _studentService.createStudent(
        accessToken: accessToken,
        studentUpdate: studentUpdate,
      );
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> enableStudent(int id, bool enable) async {
    _setLoading(true);
    try {
      final accessToken = await _tokenService.getToken();
      await _studentService.enableDisable(
          accessToken: accessToken, id: id, enable: enable);
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStudent(StudentUpdate studentUpdate) async {
    _setLoading(true);

    try {
      final accessToken = await _tokenService.getToken();
      await _studentService.updateStudent(
        accessToken: accessToken,
        studentUpdate: studentUpdate,
      );
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteStudent(int studentId) async {
    _setLoading(true);

    try {
      final accessToken = await _tokenService.getToken();
      await _studentService.deleteStudent(
        accessToken: accessToken,
        studentId: studentId,
      );
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }
}
