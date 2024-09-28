class StudentException implements Exception {
  final String message;
  StudentException(this.message);

  @override
  String toString() => message;
}