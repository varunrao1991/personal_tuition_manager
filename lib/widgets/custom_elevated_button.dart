import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final IconData? icon;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: Theme.of(context).textTheme.titleSmall,
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                textWidget,
              ],
            )
          : textWidget,
    );
  }
}
