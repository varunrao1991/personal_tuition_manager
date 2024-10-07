import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/student_update.dart';
import '../services/student_service.dart';
import '../services/token_service.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _studentService;
  final TokenService _tokenService;

  List<Student> _students = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  StudentProvider(this._studentService, this._tokenService);

  Future<void> fetchStudents({
    int? page,
    String? sort,
    String? order,
    String? name,
  }) async {
    _isLoading = true;
    notifyListeners();

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
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _tokenService.getToken();
      await _studentService.createStudent(
        accessToken: accessToken,
        studentUpdate: studentUpdate,
      );
      await resetAndFetch();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStudent(StudentUpdate studentUpdate) async {
    _isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _tokenService.getToken();
      await _studentService.updateStudent(
        accessToken: accessToken,
        studentUpdate: studentUpdate,
      );
      await resetAndFetch();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(int studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final accessToken = await _tokenService.getToken();
      await _studentService.deleteStudent(
        accessToken: accessToken,
        studentId: studentId,
      );
      await resetAndFetch();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
