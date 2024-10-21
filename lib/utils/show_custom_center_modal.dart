import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

Future<T?> showCustomDialog<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: child,
      ),
    ),
  );
}
