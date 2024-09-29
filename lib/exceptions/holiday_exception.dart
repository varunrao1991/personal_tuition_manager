class HolidayException implements Exception {
  final String message;
  HolidayException(this.message);

  @override
  String toString() => message;
}
