import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final String? tooltip;
  final String? heroTag;

  const CustomFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.heroTag = 'tag',
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon, color: iconColor),
    );
  }
}
