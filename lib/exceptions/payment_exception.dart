class PaymentException implements Exception {
  final String message;

  PaymentException(this.message);

  @override
  String toString() {
    return "PaymentException: $message";
  }
}
