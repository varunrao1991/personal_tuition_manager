import 'package:flutter/material.dart';

class InfoColumn extends StatelessWidget {
  final String value;
  final String label;
  final MainAxisAlignment mainAxisAlignment;
  final Color? color;

  const InfoColumn(
      {super.key,
      required this.value,
      required this.label,
      this.color,
      this.mainAxisAlignment = MainAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: textColor)),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: textColor)
              .copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
      ],
    );
  }
}
