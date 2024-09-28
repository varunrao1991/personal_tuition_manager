import 'package:flutter/material.dart';
import 'custom_elevated_button.dart'; // Import the custom button

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
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
              const SizedBox(width: 50.0),
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
