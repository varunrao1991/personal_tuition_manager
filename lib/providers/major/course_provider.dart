import 'dart:developer';
import 'package:flutter/material.dart';
import '../../models/owned_by.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';

class CourseProvider with ChangeNotifier {
  CourseProvider(this._courseService);

  final Map<String, List<Course>> _coursesMap = {
    'ongoing': [],
    'closed': [],
    'waitlist': [],
  };

  final CourseService _courseService;

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
      final response = await _courseService.getEligibleStudents(
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
      final response = await _courseService.getCourses(
        page: page ?? _currentPage,
        sortBy: sort,
        sortOrder: order,
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
      _hasEligibleStudents = await _courseService.hasEligibleStudents();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCourse(int studentId, int totalClasses, int? subjectId) async {
    _setLoading(true);

    try {
      await _courseService.createCourse(
        totalClasses,
        studentId,
        subjectId
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
      await _courseService.startCourseById(
        studentId,
        startDate,
      );
      log('Course successfully started.');
      await resetAndFetch(filterBy: 'ongoing');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> endCourse(int courseId, DateTime endDate) async {
    _setLoading(true);

    try {
      await _courseService.endCourseById(
        courseId,
        endDate,
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
    int? subjectId
  ) async {
    _setLoading(true);

    try {
      await _courseService.updateCourseById(
        courseId,
        totalClasses,
        subjectId
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
      await _courseService.deleteCourse(
        courseId,
      );
      log('Course successfully deleted.');

      await resetAndFetch(filterBy: 'waitlist');
    } finally {
      _setLoading(false);
    }
  }
}
