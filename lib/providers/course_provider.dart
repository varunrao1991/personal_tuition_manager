import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import '../services/token_service.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];
  bool _isLoading = false;
  final CourseService _courseService;
  final TokenService _tokenService;

  int _currentPage = 1;
  int _totalPages = 1;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  CourseProvider(this._courseService, this._tokenService);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchCourses({
    int? page,
    String? sort,
    String? order,
    String? filterBy,
  }) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();

      final response = await _courseService.getCourses(
        accessToken: accessToken,
        page: page ?? _currentPage,
        sort: sort,
        order: order,
        filterBy: filterBy,
      );

      if (page == 1 || page == null) {
        _courses = response.courses;
      } else {
        _courses.addAll(response.courses);
      }

      _currentPage = response.currentPage;
      _totalPages = response.totalPages;

      log('Courses successfully fetched.');
    } finally {
      _setLoading(
          false); // Ensure loading is set to false regardless of success or failure
    }
  }

  Future<void> resetAndFetch({
    String? sort,
    String? order,
    String? filterBy,
  }) async {
    _currentPage = 1;
    await fetchCourses(page: 1, sort: sort, order: order, filterBy: filterBy);
  }

  Future<void> addCourse(int studentId, int totalClasses) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();

      await _courseService.addCourse(
        accessToken: accessToken,
        totalClasses: totalClasses,
        studentId: studentId,
      );
      log('Course successfully added.');
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startCourse(int studentId, DateTime startDate) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();

      await _courseService.startCourse(
        accessToken: accessToken,
        studentId: studentId,
        startDate: startDate,
      );
      log('Course successfully started.');
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> endCourse(int studentId, DateTime endDate) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();

      await _courseService.endCourse(
        accessToken: accessToken,
        studentId: studentId,
        endDate: endDate,
      );
      log('Course successfully ended.');
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCourse(
    int courseId, {
    int? totalClasses,
    DateTime? startDate,
  }) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();

      await _courseService.updateCourse(
        accessToken: accessToken,
        courseId: courseId,
        totalClasses: totalClasses,
        startDate: startDate,
      );
      log('Course successfully updated.');
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCourse(int courseId) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();

      await _courseService.deleteCourse(
        accessToken: accessToken,
        courseId: courseId,
      );
      log('Course successfully deleted.');
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }
}
