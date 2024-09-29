class AttendanceException implements Exception {
  final String message;
  AttendanceException(this.message);

  @override
  String toString() => message;
}
