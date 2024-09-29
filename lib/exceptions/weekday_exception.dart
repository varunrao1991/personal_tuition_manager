class WeekdayException implements Exception {
  final String message;
  WeekdayException(this.message);

  @override
  String toString() => message;
}
