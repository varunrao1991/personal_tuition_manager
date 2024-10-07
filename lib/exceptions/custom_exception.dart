class CustomException implements Exception {
  final String message;
  final String errorCode;

  CustomException(this.message, this.errorCode);

  @override
  String toString() => 'CustomException: $message (Error code: $errorCode)';
}

class TokenIsNullException extends CustomException {
  TokenIsNullException(String message) : super(message, 'NULL_TOKEN');
}

class ExpiredTokenException extends CustomException {
  ExpiredTokenException(String message) : super(message, 'EXPIRED_TOKEN');
}

class InvalidTokenException extends CustomException {
  InvalidTokenException(String message) : super(message, 'INVALID_TOKEN');
}

class UnauthrosizedException extends CustomException {
  UnauthrosizedException(String message) : super(message, 'UNAUTHORIZED');
}

class BadRequestException extends CustomException {
  BadRequestException(String message) : super(message, 'BAD_REQUEST');
}

class NotFoundException extends CustomException {
  NotFoundException(String message) : super(message, 'NOT_FOUND');
}

class ConflictException extends CustomException {
  ConflictException(String message) : super(message, 'CONFLICT');
}

class InternalServerErrorException extends CustomException {
  InternalServerErrorException(String message)
      : super(message, 'INTERNAL_SERVER_ERROR');
}
