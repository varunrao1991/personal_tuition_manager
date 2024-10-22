import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../models/student/course.dart';
import '../../utils/response_to_error.dart';

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

  Future<CourseResponse> getCourses(
      {required String accessToken,
      required int page,
      String? sort,
      String? order}) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
    };

    if (sort != null) queryParams['sort'] = sort;
    if (order != null) queryParams['order'] = order;

    Uri uri = Uri.parse('$apiUrl/api/courses/my_courses')
        .replace(queryParameters: queryParams);

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
