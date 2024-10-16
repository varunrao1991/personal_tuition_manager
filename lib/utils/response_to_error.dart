import '../exceptions/custom_exception.dart';
import 'dart:convert';

Exception responseToError(String responseBody) {
  final Map<String, dynamic> errorResponse = jsonDecode(responseBody);

  if (errorResponse.containsKey('errorCode')) {
    final String errorCode = errorResponse['errorCode'];
    final String message = errorResponse['error'] ?? 'An error occurred';

    switch (errorCode) {
      case 'NULL_TOKEN':
        return TokenIsNullException(message);
      case 'EXPIRED_TOKEN':
        return ExpiredTokenException(message);
      case 'INVALID_TOKEN':
        return InvalidTokenException(message);
      case 'UNAUTHORIZED':
        return UnauthrosizedException(message);
      case 'BAD_REQUEST':
        return BadRequestException(message);
      case 'NOT_FOUND':
        return NotFoundException(message);
      case 'CONFLICT':
        return ConflictException(message);
      case 'INTERNAL_SERVER_ERROR':
        return InternalServerErrorException(message);
      default:
        return CustomException(message, errorCode);
    }
  } else {
    return CustomException('Unknown error occurred', 'UNKNOWN_ERROR');
  }
}
