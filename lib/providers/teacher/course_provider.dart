import 'dart:developer';
import 'package:flutter/material.dart';
import '../../models/owned_by.dart';
import '../../models/teacher/course.dart';
import '../../services/teacher/course_service.dart';
import '../../services/token_service.dart';

class CourseProvider with ChangeNotifier {
  CourseProvider(this._courseService, this._tokenService);

  final Map<String, List<Course>> _coursesMap = {
    'ongoing': [],
    'closed': [],
    'waitlist': [],
  };

  final CourseService _courseService;
  final TokenService _tokenService;

  bool _isLoading = false;
  List<OwnedBy> _eligibleStudents = [];
  bool _hasEligibleStudents = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _currentEligibleStudentPage = 1;
  int _totalEligibleStudentPages = 1;

  Map<String, List<Course>> get coursesMap => _coursesMap;
  List<OwnedBy> get eligibleStudents => _eligibleStudents;
  bool get hasEligibleStudents => _hasEligibleStudents;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get currentEligibleStudentPage => _currentEligibleStudentPage;
  int get totalEligibleStudentPages => _totalEligibleStudentPages;

  void clearData() {
    _setLoading(true);
    _eligibleStudents = [];
    _hasEligibleStudents = false;
    _currentPage = 1;
    _totalPages = 1;
    _currentEligibleStudentPage = 1;
    _totalEligibleStudentPages = 1;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchEligibleStudents({int? page}) async {
    _setLoading(true);
    try {
      final accessToken = await _tokenService.getToken();
      final response = await _courseService.getEligibleStudents(
        accessToken: accessToken,
        page: page ?? _currentEligibleStudentPage,
      );

      if (page == 1 || page == null) {
        _eligibleStudents = response.students;
      } else {
        _eligibleStudents.addAll(response.students);
      }

      _currentEligibleStudentPage = response.currentPage;
      _totalEligibleStudentPages = response.totalPages;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetAndFetchEligibleStudents() async {
    _currentPage = 1;
    await fetchEligibleStudents(page: 1);
  }

  Future<void> fetchCourses({
    int? page,
    String? sort,
    String? order,
    required String filterBy,
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
        _coursesMap[filterBy] = response.courses;
      } else {
        _coursesMap[filterBy]?.addAll(response.courses);
      }

      _currentPage = response.currentPage;
      _totalPages = response.totalPages;

      log('Courses successfully fetched for $filterBy: ${response.courses.length}.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetAndFetch({
    String? sort,
    String? order,
    required String filterBy,
  }) async {
    _currentPage = 1;
    await fetchCourses(page: 1, sort: sort, order: order, filterBy: filterBy);
  }

  Future<void> existsEligibleStudents() async {
    _setLoading(true);
    try {
      final String accessToken = await _tokenService.getToken();

      _hasEligibleStudents =
          await _courseService.hasEligibleStudents(accessToken);
    } finally {
      _setLoading(false);
    }
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
      await resetAndFetch(filterBy: 'waitlist');
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
        courseId: studentId,
        startDate: startDate,
      );
      log('Course successfully started.');
      await resetAndFetch(filterBy: 'ongoing');
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
        courseId: studentId,
        endDate: endDate,
      );
      log('Course successfully ended.');
      await resetAndFetch(filterBy: 'closed');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCourse(
    int courseId,
    int totalClasses,
  ) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();

      await _courseService.updateCourse(
        accessToken: accessToken,
        courseId: courseId,
        totalClasses: totalClasses,
      );
      log('Course successfully updated.');

      await resetAndFetch(filterBy: 'ongoing');
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

      await resetAndFetch(filterBy: 'waitlist');
    } finally {
      _setLoading(false);
    }
  }
}
