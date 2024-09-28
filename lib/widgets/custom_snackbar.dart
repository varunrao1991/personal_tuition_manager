import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
  Color backgroundColor = Colors.blueAccent,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white), // Customize text color
      ),
      duration: duration,
      backgroundColor: backgroundColor,
    ),
  );
}
