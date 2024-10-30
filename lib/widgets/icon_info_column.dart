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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align labels to the start
          children: [
            Text(
              label1,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              label2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
