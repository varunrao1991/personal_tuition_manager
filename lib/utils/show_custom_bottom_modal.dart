import 'package:flutter/material.dart';

Future<T?> showCustomModalBottomSheet<T>({
  required BuildContext context,
  required Widget child,
}) {
  final theme = Theme.of(context);

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: child,
          ),
        ],
      ),
    ),
  );
}
