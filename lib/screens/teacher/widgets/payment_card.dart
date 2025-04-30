import 'package:flutter/material.dart';
import '../../../services/teacher/course_service.dart';
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

  Color _getColorBasedOnStatus(CourseStatus courseStatus) {
    switch (courseStatus) {
      case CourseStatus.noCourse:
        return Colors.green;
      case CourseStatus.notStarted:
        return Colors.orange;
      case CourseStatus.started:
        return Colors.red;
      case CourseStatus.closed:
        return Colors.grey;
      }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSwipeCard(
      onSwipeLeft: onDelete,
      onSwipeRight: onEdit,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Status indicator bar
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: _getColorBasedOnStatus(payment.courseStatus),
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(right: 16),
            ),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row - Amount and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Amount (limited to 5 digits)
                      Text(
                        '₹${payment.amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getColorBasedOnStatus(payment.courseStatus)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(payment.courseStatus),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _getColorBasedOnStatus(
                                        payment.courseStatus),
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Second row - Payment ID and Days ago
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Payment ID
                      Text(
                        'ID: ${payment.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),

                      // Days ago
                      Text(
                        timeAgoString(payment.paymentDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Student name (with ellipsis for long names)
                  Text(
                    payment.ownedBy.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(CourseStatus status) {
    switch (status) {
      case CourseStatus.noCourse:
        return 'No Course';
      case CourseStatus.notStarted:
        return 'Not Started';
      case CourseStatus.started:
        return 'Ongoing';
      case CourseStatus.closed:
        return 'Completed';
      }
  }
}
