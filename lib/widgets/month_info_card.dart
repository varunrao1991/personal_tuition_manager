import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_card.dart';

class MonthInfoCard extends StatelessWidget {
  final DateTime month;
  final bool isSelected;
  final Widget child;
  final Future<void> Function() onTap; // Change here to accept async callback

  const MonthInfoCard({
    super.key,
    required this.month,
    required this.isSelected,
    required this.child,
    required this.onTap, // Pass onTap to constructor
  });

  @override
  Widget build(BuildContext context) {
    // Calculate one-third of the screen width
    final double cardWidth = MediaQuery.of(context).size.width / 3.5;

    return SizedBox(
      width: cardWidth, // Set width to one-third of the screen width
      child: CustomCard(
        onTap: () async {
          // Call the async onTap function
          await onTap();
        },
        isSelected: isSelected,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('MMM').format(month),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('y').format(month),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            child, // Use the provided child for total payment
          ],
        ),
      ),
    );
  }
}
