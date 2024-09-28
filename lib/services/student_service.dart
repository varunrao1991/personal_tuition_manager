import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/student_model.dart';
import '../exceptions/student_exception.dart';
import '../models/student_update.dart';

class StudentResponse {
  final List<Student> students;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  StudentResponse({
    required this.students,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

class StudentService {
  final String apiUrl = Config().apiUrl;

  Future<StudentResponse> getStudents({
    required String accessToken,
    required int page,
    String? sort,
    String? order,
    String? name,
  }) async {
    // Build the query parameters
    final queryParameters = {
      'page': page.toString(),
      if (sort != null) 'sort': sort,
      if (order != null) 'order': order,
      if (name != null && name.isNotEmpty) 'name': name,
    };

    final uri = Uri.parse('$apiUrl/api/students')
        .replace(queryParameters: queryParameters);

    // Make the GET request with query parameters
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return StudentResponse(
        students: (data['data'] as List)
            .map((student) => Student.fromJson(student))
            .toList(),
        totalPages: data['totalPages'],
        totalRecords: data['totalRecords'],
        currentPage: data['currentPage'],
      );
    } else {
      throw StudentException('Failed to load students: ${response.body}');
    }
  }

  Future<void> createStudent({
    required String accessToken,
    required StudentUpdate studentUpdate,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/students'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(studentUpdate.toJson()),
    );

    if (response.statusCode != 201) {
      throw StudentException('Failed to create student: ${response.body}');
    } else {
      log(response.body);
    }
  }

  Future<void> updateStudent({
    required String accessToken,
    required StudentUpdate studentUpdate,
  }) async {
    final response = await http.put(
      Uri.parse('$apiUrl/api/students/${studentUpdate.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(studentUpdate.toJson()),
    );

    if (response.statusCode != 201) {
      throw StudentException('Failed to edit student: ${response.body}');
    } else {
      log(response.body);
    }
  }

  Future<void> deleteStudent({
    required String accessToken,
    required int studentId,
  }) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/api/students/$studentId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw StudentException('Failed to delete student: ${response.body}');
    } else {
      log(response.body);
    }
  }
}
