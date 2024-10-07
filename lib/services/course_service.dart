import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../config/app_config.dart';
import '../utils/response_to_error.dart';

class CourseResponse {
  final List<Course> courses;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  CourseResponse({
    required this.courses,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

class CourseService {
  String apiUrl = Config().apiUrl;
  final http.Client _client;

  CourseService(this._client);

  // Create a new course
  Future<void> addCourse({
    required String accessToken,
    required int totalClasses,
    required int studentId,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/courses'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'studentId': studentId, 'totalClasses': totalClasses}),
    );

    if (response.statusCode != 201) {
      throw responseToError(response.body);
    } else {
      log('Course successfully created.');
    }
  }

  // Start a course
  Future<void> startCourse({
    required String accessToken,
    required int studentId,
    required DateTime startDate,
  }) async {
    final response = await _client.patch(
      Uri.parse('$apiUrl/api/courses/start'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'studentId': studentId,
        'startDate': startDate.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log('Course successfully started.');
    }
  }

  // End a course
  Future<void> endCourse({
    required String accessToken,
    required int studentId,
    required DateTime endDate,
  }) async {
    final response = await _client.patch(
      Uri.parse('$apiUrl/api/courses/end'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'studentId': studentId,
        'endDate': endDate.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log('Course successfully ended.');
    }
  }

  // Update an existing course
  Future<void> updateCourse({
    required String accessToken,
    required int courseId,
    required int? totalClasses,
    required DateTime? startDate,
  }) async {
    final response = await _client.patch(
      Uri.parse('$apiUrl/api/courses/$courseId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (totalClasses != null) 'totalClasses': totalClasses,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log('Course successfully updated.');
    }
  }

  // Delete a course
  Future<void> deleteCourse({
    required String accessToken,
    required int courseId,
  }) async {
    final response = await _client.delete(
      Uri.parse('$apiUrl/api/courses/$courseId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log('Course successfully deleted.');
    }
  }

  Future<CourseResponse> getCourses({
    required String accessToken,
    required int page,
    String? sort,
    String? order,
    String? filterBy,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
    };

    if (sort != null) queryParams['sort'] = sort;
    if (order != null) queryParams['order'] = order;
    if (filterBy != null) queryParams['filterBy'] = filterBy;

    Uri uri =
        Uri.parse('$apiUrl/api/courses').replace(queryParameters: queryParams);

    final response = await _client.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final courses = (data['data'] as List)
          .map((courseJson) => Course.fromJson(courseJson))
          .toList();

      return CourseResponse(
        courses: courses,
        totalPages: data['totalPages'],
        totalRecords: data['totalRecords'],
        currentPage: data['currentPage'],
      );
    } else {
      throw responseToError(response.body);
    }
  }
}
