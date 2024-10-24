import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import '../exceptions/auth_exception.dart';
import '../exceptions/custom_exception.dart';
import '../widgets/custom_snackbar.dart';

void handleErrors(BuildContext context, e) {
  if (e is AuthException) {
    _handleAuthError(context, e.message);
  } else if (e is InvalidTokenException) {
    _handleInvalidTokenError(context, e.message);
  } else if (e is InvalidSessionException) {
    _handleInvalidSessionError(context, e.message);
  } else if (e is TokenIsNullException) {
    _handleNullTokenError(context, e.message);
  } else if (e is BadRequestException) {
    _handleBadRequestError(context, e.message);
  } else if (e is UnauthorizedException) {
    _handleUnauthorizedError(context, e.message);
  } else if (e is TimeoutException) {
    _handleTimeoutError(context, e.message);
  } else if (e is SocketException) {
    if (e.osError?.message == 'No route to host') {
      showCustomSnackBar(
          context, "Failed to connect to the server. Is it running?");
    } else {
      showCustomSnackBar(
          context, "No Internet connection. Check your network.");
    }
  } else if (e is HttpException) {
    showCustomSnackBar(
        context, "Failed to connect to the server. Is it running?");
  } else if (e is FormatException) {
    showCustomSnackBar(context, "Invalid response format.");
  } else if (e is CustomException) {
    showCustomSnackBar(context, e.message);
  } else if (e is Error) {
    showCustomSnackBar(
        context, 'An unexpected error occurred: ${e.toString()}');
    log(e.stackTrace.toString());
  } else {
    _handleGeneralError(context, e);
  }
}

void _handleTimeoutError(BuildContext context, String? message) {
  showCustomSnackBar(
      context, 'Request timed out. Please try again later. $message',
      backgroundColor: Colors.orangeAccent);
}

void _handleInvalidTokenError(BuildContext context, String? message) {
  showCustomSnackBar(context, 'Session expired; Login again.',
      backgroundColor: Colors.orangeAccent);
  Navigator.of(context).pushReplacementNamed('/login');
}

void _handleInvalidSessionError(BuildContext context, String? message) {
  showCustomSnackBar(context, 'Session invalid; Login again.',
      backgroundColor: Colors.orangeAccent);
  Navigator.of(context).pushReplacementNamed('/login');
}

void _handleNullTokenError(BuildContext context, String? message) {
  showCustomSnackBar(context, 'Null token; Login again.',
      backgroundColor: Colors.orangeAccent);
  Navigator.of(context).pushReplacementNamed('/login');
}

void _handleAuthError(BuildContext context, String message) {
  showCustomSnackBar(context, message, backgroundColor: Colors.pinkAccent);
}

void _handleUnauthorizedError(BuildContext context, String message) {
  showCustomSnackBar(context, message, backgroundColor: Colors.redAccent);
}

void _handleBadRequestError(BuildContext context, String message) {
  showCustomSnackBar(context, message);
}

void _handleGeneralError(BuildContext context, Exception e) {
  showCustomSnackBar(context, 'An unknown error occurred: ${e.toString()}',
      backgroundColor: Colors.brown);
  log(e.toString());
}
