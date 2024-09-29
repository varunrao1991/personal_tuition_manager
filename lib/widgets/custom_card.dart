import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final double borderRadius;
  final VoidCallback? onTap; // Add a callback for tap functionality

  const CustomCard({
    super.key,
    required this.child,
    this.elevation = 4.0,
    this.borderRadius = 15.0,
    this.onTap, // Include the onTap parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Call the onTap callback if provided
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}
