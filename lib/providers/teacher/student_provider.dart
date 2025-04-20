import 'dart:developer';

import 'package:flutter/material.dart';
import '../../models/teacher/student_model.dart';
import '../../models/teacher/student_update.dart';
import '../../services/teacher/student_service.dart';

class StudentProvider with ChangeNotifier {
  StudentProvider(this._studentService);

  final StudentService _studentService;

  bool _isLoading = false;
  List<Student> _students = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _anyUserExists = true;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get anyUserExists => _anyUserExists;

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
      final response = await _studentService.getStudents(
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
      await _studentService.createStudent(
        studentUpdate: studentUpdate,
      );
      await resetAndFetch();
      _anyUserExists = await _studentService.anyUserExists();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStudentsExists() async {
    _setLoading(true);
    try {
      _anyUserExists = await _studentService.anyUserExists();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStudent(StudentUpdate studentUpdate) async {
    _setLoading(true);

    try {
      await _studentService.updateStudent(
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
      await _studentService.deleteStudent(
        studentId: studentId,
      );
      await resetAndFetch();
      bool userExists = await _studentService.anyUserExists();
      _anyUserExists = userExists;
    } finally {
      _setLoading(false);
    }
  }
}
