import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'custom_elevated_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final String confirmButtonText;
  final String cancelButtonText;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;

  const ConfirmationDialog({
    super.key,
    required this.message,
    required this.confirmButtonText,
    this.cancelButtonText = 'Cancel',
    this.confirmButtonColor,
    this.cancelButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppPaddings.smallPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Confirmation',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10.0),
          Text(
            message,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomElevatedButton(
                  text: cancelButtonText,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ),
              const SizedBox(width: AppMargins.mediumMargin),
              Expanded(
                child: CustomElevatedButton(
                  text: confirmButtonText,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
