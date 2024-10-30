import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/fetch_payment.dart';
import '../../../utils/time_ago.dart';
import '../../../widgets/custom_swipe_card.dart';

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

  Color _getColorBasedOnStatus(int courseStatus) {
    switch (courseStatus) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.red;
      case 3:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSwipeCard(
        onSwipeLeft: onDelete,
        onSwipeRight: onEdit,
        child: Row(
          children: [
            Container(
              width: 4,
              height: 90,
              color: _getColorBasedOnStatus(payment.courseStatus),
              margin: const EdgeInsets.only(right: 12.0),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('₹ ${payment.amount}',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(timeAgoString(payment.paymentDate),
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(payment.ownedBy.name,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ));
  }
}
