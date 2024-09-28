import 'package:flutter/material.dart';
import 'package:padmayoga/models/fetch_payment.dart';

import '../../../widgets/custom_swipe_card.dart'; // Adjust the import as per your project structure

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSwipeCard(
      onSwipeLeft: onDelete,
      onSwipeRight: onEdit,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Amount: ₹${payment.amount}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Paid By: ${payment.paidBy.name}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  payment.paymentDate.toLocal().toString().split(' ')[0],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
