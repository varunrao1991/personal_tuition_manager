import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_card.dart';

class MonthInfoCard extends StatelessWidget {
  final DateTime month;
  final bool isSelected;
  final Widget child;
  final Future<void> Function() onTap;

  const MonthInfoCard({
    super.key,
    required this.month,
    required this.isSelected,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width / 3.5;

    return SizedBox(
      width: cardWidth,
      child: CustomCard(
        onTap: () async {
          await onTap();
        },
        isSelected: isSelected,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('MMM').format(month),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(DateFormat('y').format(month),
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }
}
