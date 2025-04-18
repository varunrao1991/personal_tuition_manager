// Centralized error codes
class ErrorCodes {
  static const String nullToken = 'NULL_TOKEN';
  static const String invalidSession = 'INVALID_SESSION';
  static const String expiredToken = 'EXPIRED_TOKEN';
  static const String invalidToken = 'INVALID_TOKEN';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String badRequest = 'BAD_REQUEST';
  static const String notFound = 'NOT_FOUND';
  static const String pinNotSet = "PIN_NOT_SET";
  static const String pinIncorrect = "PIN_INCORRECT";
  static const String pinMismatch = "PIN_MISMATCH";
  static const String securityNotSet = "SECURITY_NOT_SET";
  static const String securityAnswerIncorrect = "SECURITY_ANSWER_INCORRECT";
  static const String conflict = 'CONFLICT';
  static const String unknownError = 'UNKNOWN_ERROR';
  static const String internalServerError = 'INTERNAL_SERVER_ERROR';
}

// Base CustomException class
class CustomException implements Exception {
  final String message;
  final String errorCode;

  CustomException(this.message, this.errorCode);

  @override
  String toString() => 'CustomException: $message (Error code: $errorCode)';
}

// Specific exception classes
class TokenIsNullException extends CustomException {
  TokenIsNullException(String message) : super(message, ErrorCodes.nullToken);
}

class InvalidSessionException extends CustomException {
  InvalidSessionException(String message)
      : super(message, ErrorCodes.invalidSession);
}

class ExpiredTokenException extends CustomException {
  ExpiredTokenException(String message)
      : super(message, ErrorCodes.expiredToken);
}

class InvalidTokenException extends CustomException {
  InvalidTokenException(String message)
      : super(message, ErrorCodes.invalidToken);
}

class UnauthorizedException extends CustomException {
  UnauthorizedException(String message)
      : super(message, ErrorCodes.unauthorized);
}

class BadRequestException extends CustomException {
  BadRequestException(String message) : super(message, ErrorCodes.badRequest);
}

class NotFoundException extends CustomException {
  NotFoundException(String message) : super(message, ErrorCodes.notFound);
}

class ConflictException extends CustomException {
  ConflictException(String message) : super(message, ErrorCodes.conflict);
}

class InternalServerErrorException extends CustomException {
  InternalServerErrorException(String message)
      : super(message, ErrorCodes.internalServerError);
}

class PinMismatchException extends CustomException {
  PinMismatchException(String message)
      : super(message, ErrorCodes.pinMismatch);
}

class PinNotSetException extends CustomException {
  PinNotSetException(String message)
      : super(message, ErrorCodes.pinNotSet);
}

class PinIncorrectException extends CustomException {
  PinIncorrectException(String message)
      : super(message, ErrorCodes.pinIncorrect);
}

class PinSecurityNotSetException extends CustomException {
  PinSecurityNotSetException(String message)
      : super(message, ErrorCodes.securityNotSet);
}

class PinSecurityAnswerNotCorrectException extends CustomException {
  PinSecurityAnswerNotCorrectException(String message)
      : super(message, ErrorCodes.securityAnswerIncorrect);
}