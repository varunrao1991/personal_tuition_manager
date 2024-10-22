import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

Future<T?> showCustomDialog<T>({
  required BuildContext context,
  required Widget child,
}) {
  final screenWidth = MediaQuery.of(context).size.width;

  return showDialog<T>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: screenWidth > 600 ? 400 : screenWidth * 0.8, // Responsive width
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        constraints: const BoxConstraints(maxWidth: 400), // Limits max width
        child: child,
      ),
    ),
  );
}
