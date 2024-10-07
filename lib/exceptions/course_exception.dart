class CourseException implements Exception {
  final String message;
  CourseException(this.message);

  @override
  String toString() => message;
}
