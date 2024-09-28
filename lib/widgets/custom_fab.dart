import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;

  const CustomFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: backgroundColor,
      onPressed: onPressed,
      child: Icon(icon, color: iconColor),
    );
  }
}
