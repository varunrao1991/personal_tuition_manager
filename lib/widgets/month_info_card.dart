import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_card.dart'; // Import your custom card

class MonthInfoCard extends StatelessWidget {
  final DateTime month;
  final bool isSelected;
  final Widget child;
  final VoidCallback onTap; // Add onTap to handle clicks

  const MonthInfoCard({
    super.key,
    required this.month,
    required this.isSelected,
    required this.child,
    required this.onTap, // Pass onTap to constructor
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap, // Use the onTap callback from CustomCard
      elevation: 4.0,
      borderRadius: 8.0,
      child: Container(
        width: 100, // Adjust width as needed
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blueAccent : Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
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
