import 'package:flutter/material.dart';

class IconInfoColumn extends StatelessWidget {
  final IconData icon;
  final String label1;
  final String label2;

  const IconInfoColumn({
    super.key,
    required this.icon,
    required this.label1,
    required this.label2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 8),
        Text(
          label1,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(width: 4),
        Text(
          label2,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
