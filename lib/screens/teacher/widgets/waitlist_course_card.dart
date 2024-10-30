import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_swipe_card.dart';
import '../../../widgets/info_column.dart';
import '../../../utils/time_ago.dart';

class WaitlistCourseCard extends StatelessWidget {
  final String studentName;
  final int studentId;
  final int totalClasses;
  final DateTime paymentDate;
  final bool canStart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStart;
  final VoidCallback? onTap;

  const WaitlistCourseCard({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.totalClasses,
    required this.paymentDate,
    required this.canStart,
    required this.onEdit,
    required this.onDelete,
    required this.onStart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSwipeCard(
      onTap: onTap,
      onSwipeLeft: onDelete,
      onSwipeRight: onEdit,
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.tinyPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(studentName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paid ${timeAgoString(paymentDate)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      InfoColumn(
                        mainAxisAlignment: MainAxisAlignment.start,
                        value: '$totalClasses',
                        label: 'Classes',
                      ),
                    ],
                  ),
                ),
                CustomElevatedButton(
                  text: 'Start Course',
                  onPressed: canStart ? onStart : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
