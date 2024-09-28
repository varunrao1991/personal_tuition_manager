import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/student_update.dart';
import '../services/student_service.dart';
import '../services/token_service.dart';
import '../exceptions/student_exception.dart'; // Import your custom exception

class StudentProvider with ChangeNotifier {
  final StudentService _studentService;
  final TokenService _tokenService;

  List<Student> _students = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  // Getters to access provider state
  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  // Constructor to inject TokenService and StudentService
  StudentProvider(this._studentService, this._tokenService);

  // Fetch students with pagination and optional sorting/filtering
  Future<void> fetchStudents({
    int? page,
    String? sort,
    String? order,
    String? name,
  }) async {
    _isLoading = true;
    notifyListeners(); // Notify UI that loading has started

    try {
      // Retrieve access token from TokenService
      String? accessToken = await _tokenService.getToken();

      if (accessToken == null) {
        throw StudentException(
            "No access token available. Please log in again.");
      }

      // Fetch students from StudentService
      final response = await _studentService.getStudents(
        accessToken: accessToken,
        page: page ?? _currentPage,
        sort: sort,
        order: order,
        name: name,
      );

      // Handle pagination: Reset the list for page 1, append for other pages
      if (page == 1 || page == null) {
        _students = response.students; // Reset on first page load or refresh
      } else {
        _students.addAll(response.students); // Append for paginated results
      }

      // Update pagination details
      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
    } catch (e) {
      log('Error fetching students: $e');
      // Handle the custom exception and notify UI
      if (e is StudentException) {
        rethrow; // Re-throw if you want to handle it elsewhere
      } else {
        throw StudentException('An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is done
    }
  }

  // Reset the student list and fetch from page 1 (useful for filtering or refresh)
  Future<void> resetAndFetch({
    String? sort,
    String? order,
    String? name,
  }) async {
    _currentPage = 1; // Reset to the first page
    await fetchStudents(page: 1, sort: sort, order: order, name: name);
  }

  // Method to create a new student
  Future<void> createStudent(StudentUpdate studentUpdate) async {
    _isLoading = true;
    notifyListeners(); // Notify UI that loading has started

    try {
      // Retrieve access token from TokenService
      String? accessToken = await _tokenService.getToken();

      if (accessToken == null) {
        throw StudentException(
            "No access token available. Please log in again.");
      }

      // Create the student using the StudentService
      await _studentService.createStudent(
        accessToken: accessToken,
        studentUpdate: studentUpdate,
      );

      // Optionally, reset the student list or fetch students again
      await resetAndFetch();
    } catch (e) {
      log('Error creating student: $e'); // Consider using a logging library
      if (e is StudentException) {
        rethrow; // Re-throw if you want to handle it elsewhere
      } else {
        throw StudentException('An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is done
    }
  }

  // Method to create a new student
  Future<void> updateStudent(StudentUpdate studentUpdate) async {
    _isLoading = true;
    notifyListeners(); // Notify UI that loading has started

    try {
      // Retrieve access token from TokenService
      String? accessToken = await _tokenService.getToken();

      if (accessToken == null) {
        throw StudentException(
            "No access token available. Please log in again.");
      }

      // Create the student using the StudentService
      await _studentService.updateStudent(
        accessToken: accessToken,
        studentUpdate: studentUpdate,
      );

      // Optionally, reset the student list or fetch students again
      await resetAndFetch();
    } catch (e) {
      log('Error creating student: $e'); // Consider using a logging library
      if (e is StudentException) {
        rethrow; // Re-throw if you want to handle it elsewhere
      } else {
        throw StudentException('An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is done
    }
  }

  // Method to create a new student
  Future<void> deleteStudent(int studentId) async {
    _isLoading = true;
    notifyListeners(); // Notify UI that loading has started

    try {
      // Retrieve access token from TokenService
      String? accessToken = await _tokenService.getToken();

      if (accessToken == null) {
        throw StudentException(
            "No access token available. Please log in again.");
      }

      // Create the student using the StudentService
      await _studentService.deleteStudent(
        accessToken: accessToken,
        studentId: studentId,
      );

      // Optionally, reset the student list or fetch students again
      await resetAndFetch();
    } catch (e) {
      log('Error deleting student: $e'); // Consider using a logging library
      if (e is StudentException) {
        rethrow; // Re-throw if you want to handle it elsewhere
      } else {
        throw StudentException('An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is done
    }
  }
}
