import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../models/teacher/student_model.dart';
import '../../models/teacher/student_update.dart';
import '../../utils/response_to_error.dart';

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
  final http.Client _client;

  StudentService(this._client);

  Future<StudentResponse> getStudents({
    required String accessToken,
    required int page,
    String? sort,
    String? order,
    String? name,
  }) async {
    final queryParameters = {
      'page': page.toString(),
      if (sort != null) 'sort': sort,
      if (order != null) 'order': order,
      if (name != null && name.isNotEmpty) 'name': name,
    };

    final uri = Uri.parse('$apiUrl/api/students')
        .replace(queryParameters: queryParameters);

    final response = await _client.get(
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
      throw responseToError(response.body);
    }
  }

  Future<void> createStudent({
    required String accessToken,
    required StudentUpdate studentUpdate,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/students'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(studentUpdate.toJson()),
    );

    if (response.statusCode != 201) {
      throw responseToError(response.body);
    } else {
      log("Student created.");
    }
  }

  Future<void> updateStudent({
    required String accessToken,
    required StudentUpdate studentUpdate,
  }) async {
    final response = await _client.put(
      Uri.parse('$apiUrl/api/students/${studentUpdate.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(studentUpdate.toJson()),
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log("Student updated.");
    }
  }
  
  Future<void> enableDisable({
    required String accessToken,
    required int id,
    required bool enable,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/students/enable'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'id': id, 'enabled': enable}),
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log("Student updated.");
    }
  }

  Future<void> deleteStudent({
    required String accessToken,
    required int studentId,
  }) async {
    final response = await _client.delete(
      Uri.parse('$apiUrl/api/students/$studentId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log("Student deleted.");
    }
  }
}
