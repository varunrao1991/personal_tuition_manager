import 'dart:developer';

import 'package:flutter/material.dart';
import '../../models/admin/teacher_model.dart';
import '../../models/admin/teacher_update.dart';
import '../../services/admin/teacher_service.dart';
import '../../services/token_service.dart';

class TeacherProvider with ChangeNotifier {
  TeacherProvider(this._teacherService, this._tokenService);

  final TeacherService _teacherService;
  final TokenService _tokenService;

  bool _isLoading = false;
  List<Teacher> _teachers = [];
  int _currentPage = 1;
  int _totalPages = 1;

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  void clearData() {
    _setLoading(true);
    _teachers = [];
    _currentPage = 1;
    _totalPages = 1;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchTeachers({
    int? page,
    String? sort,
    String? order,
    String? name,
  }) async {
    _setLoading(true);

    try {
      final accessToken = await _tokenService.getToken();
      final response = await _teacherService.getTeachers(
        accessToken: accessToken,
        page: page ?? _currentPage,
        sort: sort,
        order: order,
        name: name,
      );

      if (page == 1 || page == null) {
        _teachers = response.teachers;
      } else {
        _teachers.addAll(response.teachers);
      }

      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      log('Teachers successfully fetched for $_currentPage: ${response.teachers.length}.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> enableTeacher(int id, bool enable) async {
    _setLoading(true);
    try {
      final accessToken = await _tokenService.getToken();
      await _teacherService.enableDisable(
          accessToken: accessToken, id: id, enable: enable);
      await resetAndFetch();
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
    await fetchTeachers(page: 1, sort: sort, order: order, name: name);
  }

  Future<void> createTeacher(TeacherUpdate teacherUpdate) async {
    _setLoading(true);

    try {
      final accessToken = await _tokenService.getToken();
      await _teacherService.createTeacher(
        accessToken: accessToken,
        teacherUpdate: teacherUpdate,
      );
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTeacher(TeacherUpdate teacherUpdate) async {
    _setLoading(true);

    try {
      final accessToken = await _tokenService.getToken();
      await _teacherService.updateTeacher(
        accessToken: accessToken,
        teacherUpdate: teacherUpdate,
      );
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTeacher(int teacherId) async {
    _setLoading(true);

    try {
      final accessToken = await _tokenService.getToken();
      await _teacherService.deleteTeacher(
        accessToken: accessToken,
        teacherId: teacherId,
      );
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }
}
