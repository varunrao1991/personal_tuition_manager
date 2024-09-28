import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120, // Set a minimum width for the button
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: const EdgeInsets.symmetric(
              vertical: 15), // Adjust vertical padding
          backgroundColor: Colors.blueAccent,
          shadowColor:
              Colors.black.withOpacity(0.3), // Add a shadow color for depth
          elevation: 5, // Set a subtle elevation
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
