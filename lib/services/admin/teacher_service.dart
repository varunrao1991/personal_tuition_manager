import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../models/admin/teacher_model.dart';
import '../../models/admin/teacher_update.dart';
import '../../utils/response_to_error.dart';

class TeacherResponse {
  final List<Teacher> teachers;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  TeacherResponse({
    required this.teachers,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

class TeacherService {
  final String apiUrl = Config().apiUrl;
  final http.Client _client;

  TeacherService(this._client);

  Future<TeacherResponse> getTeachers({
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

    final uri = Uri.parse('$apiUrl/api/admin/teachers')
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
      return TeacherResponse(
        teachers: (data['data'] as List)
            .map((teacher) => Teacher.fromJson(teacher))
            .toList(),
        totalPages: data['totalPages'],
        totalRecords: data['totalRecords'],
        currentPage: data['currentPage'],
      );
    } else {
      throw responseToError(response.body);
    }
  }

  Future<void> createTeacher({
    required String accessToken,
    required TeacherUpdate teacherUpdate,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/admin/teachers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(teacherUpdate.toJson()),
    );

    if (response.statusCode != 201) {
      throw responseToError(response.body);
    } else {
      log("Teacher created.");
    }
  }

  Future<void> updateTeacher({
    required String accessToken,
    required TeacherUpdate teacherUpdate,
  }) async {
    final response = await _client.put(
      Uri.parse('$apiUrl/api/admin/teachers/${teacherUpdate.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(teacherUpdate.toJson()),
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log("Teacher updated.");
    }
  }

  Future<void> deleteTeacher({
    required String accessToken,
    required int teacherId,
  }) async {
    final response = await _client.delete(
      Uri.parse('$apiUrl/api/admin/teachers/$teacherId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log("Teacher deleted.");
    }
  }
}
