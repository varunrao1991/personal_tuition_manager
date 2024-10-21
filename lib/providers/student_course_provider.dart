import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/student_course.dart';
import '../services/course_service.dart';
import '../services/token_service.dart';

class StudentCourseProvider with ChangeNotifier {
  StudentCourseProvider(this._courseService, this._tokenService);

  List<StudentCourse> _courses = [];

  final CourseService _courseService;
  final TokenService _tokenService;

  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  bool get isLoading => _isLoading;
  List<StudentCourse> get courses => _courses;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  void clearData() {
    _setLoading(true);
    _currentPage = 1;
    _currentPage = 1;
    _totalPages = 1;
    _courses.clear();
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchCourses({
    int? page,
    String? sort,
    String? order,
  }) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();

      final response = await _courseService.getMyCourses(
        accessToken: accessToken,
        page: page ?? _currentPage,
        sort: sort,
        order: order,
      );

      if (page == 1 || page == null) {
        _courses = response.courses;
      } else {
        _courses.addAll(response.courses);
      }

      _currentPage = response.currentPage;
      _totalPages = response.totalPages;

      log('Courses successfully fetched: ${response.courses.length}.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetAndFetch({
    String? sort,
    String? order,
  }) async {
    _currentPage = 1;
    await fetchCourses(page: 1, sort: sort, order: order);
  }
}
