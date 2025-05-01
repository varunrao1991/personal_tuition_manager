class DatabaseInstanceException implements Exception {
  final String message;
  DatabaseInstanceException(this.message);

  @override
  String toString() => message;
}