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
    final Color? backgroundColor = isEnabled
        ? Theme.of(context).floatingActionButtonTheme.foregroundColor
        : Theme.of(context)
            .floatingActionButtonTheme
            .foregroundColor!
            .withOpacity(0.5);

    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: isEnabled ? onPressed : null,
      tooltip: tooltip,
      foregroundColor: backgroundColor,
      child: Icon(icon),
    );
  }
}
