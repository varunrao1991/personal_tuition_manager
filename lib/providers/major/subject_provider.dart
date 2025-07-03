import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:personal_tuition_manager/models/subject.dart';
import '../../services/subject_service.dart';

class SubjectProvider with ChangeNotifier {
  SubjectProvider(this._subjectService);

  final SubjectService _subjectService;

  bool _isLoading = false;
  List<Subject> _subjects = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _anySubjectExists = true;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get anySubjectExists => _anySubjectExists;

  void clearData() {
    _setLoading(true);
    _subjects = [];
    _currentPage = 1;
    _totalPages = 1;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchSubjects({
    int? page,
    required String sort,
    required String order,
    String? name,
  }) async {
    _setLoading(true);

    try {
      final response = await _subjectService.getSubjects(
        page: page ?? _currentPage,
        sort: sort,
        order: order,
        name: name,
      );

      if (page == 1 || page == null) {
        _subjects = response.subjects;
      } else {
        _subjects.addAll(response.subjects);
      }

      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      log('Subjects successfully fetched for $_currentPage: ${response.subjects.length}.');
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
    await fetchSubjects(
        page: 1, sort: sort ?? 'name', order: order ?? 'ASC', name: name);
  }

  Future<void> createSubject(SubjectUpdate subjectUpdate) async {
    _setLoading(true);

    try {
      await _subjectService.createSubject(
        subjectUpdate: subjectUpdate,
      );
      await resetAndFetch();
      _anySubjectExists = await _subjectService.anySubjectExists();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSubjectsExists() async {
    _setLoading(true);
    try {
      _anySubjectExists = await _subjectService.anySubjectExists();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSubject(SubjectUpdate subjectUpdate) async {
    _setLoading(true);

    try {
      await _subjectService.updateSubject(
        subjectUpdate: subjectUpdate,
      );
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSubject(int subjectId) async {
    _setLoading(true);

    try {
      await _subjectService.deleteSubject(
        subjectId: subjectId,
      );
      await resetAndFetch();
      bool subjectExists = await _subjectService.anySubjectExists();
      _anySubjectExists = subjectExists;
    } finally {
      _setLoading(false);
    }
  }

  // Additional methods specific to Subject functionality
  Future<List<Subject>> getAllSubjects() async {
    return await _subjectService.getAllSubjects();
  }

  Future<Subject?> getSubjectById(int id) async {
    return await _subjectService.getSubjectById(id);
  }

  Future<bool> isSubjectNameExists(String name, {int? excludeId}) async {
    return await _subjectService.isSubjectNameExists(name,
        excludeId: excludeId);
  }

  Future<List<Subject>> searchSubjects(String query) async {
    return await _subjectService.searchSubjects(query);
  }

  Future<int> getSubjectUsageCount(int subjectId) async {
    return await _subjectService.getSubjectUsageCount(subjectId);
  }

  Future<List<Map<String, dynamic>>> getSubjectsWithUsageCount() async {
    return await _subjectService.getSubjectsWithUsageCount();
  }
}
