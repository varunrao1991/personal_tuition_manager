import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
  Color? backgroundColor,
}) {
  final theme = Theme.of(context);

  final snackBarBackgroundColor = backgroundColor ?? theme.colorScheme.primary;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: theme.colorScheme.onPrimary),
      ),
      duration: duration,
      backgroundColor: snackBarBackgroundColor,
    ),
  );
}
