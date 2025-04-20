import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? heroTag;
  final bool isEnabled;

  const CustomFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.heroTag = 'tag',
    this.tooltip,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: isEnabled
          ? Theme.of(context).floatingActionButtonTheme.backgroundColor
          : Colors.grey[300],
      foregroundColor: isEnabled
          ? Theme.of(context).floatingActionButtonTheme.foregroundColor
          : Colors.grey[600],
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
