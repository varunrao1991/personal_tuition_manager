import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isSelected;

  const CustomCard(
      {super.key,
      required this.child,
      this.elevation = 4.0,
      this.borderRadius = 15.0,
      this.onTap,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.white,
            border:
                isSelected ? Border.all(color: Colors.blue, width: 2) : null,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child, // The content of the card
        ),
      ),
    );
  }
}
