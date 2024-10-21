import '../exceptions/custom_exception.dart';
import 'dart:convert';

Exception responseToError(String responseBody) {
  final Map<String, dynamic> errorResponse = jsonDecode(responseBody);

  if (errorResponse.containsKey('errorCode')) {
    final String errorCode = errorResponse['errorCode'];
    final String message = errorResponse['error'] ?? 'An error occurred';

    switch (errorCode) {
      case ErrorCodes.nullToken:
        return TokenIsNullException(message);
      case ErrorCodes.expiredToken:
        return ExpiredTokenException(message);
      case ErrorCodes.invalidSession:
        return InvalidSessionException(message);
      case ErrorCodes.invalidToken:
        return InvalidTokenException(message);
      case ErrorCodes.unauthorized:
        return UnauthorizedException(message);
      case ErrorCodes.badRequest:
        return BadRequestException(message);
      case ErrorCodes.notFound:
        return NotFoundException(message);
      case ErrorCodes.conflict:
        return ConflictException(message);
      case ErrorCodes.internalServerError:
        return InternalServerErrorException(message);
      default:
        return CustomException(message, errorCode);
    }
  } else {
    return CustomException('Unknown error occurred', ErrorCodes.unknownError);
  }
}
