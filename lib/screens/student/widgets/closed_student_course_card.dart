import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../utils/time_ago.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/icon_info_column.dart';
import '../../../widgets/info_column.dart';

class ClosedStudentCourseCard extends StatelessWidget {
  final bool isSelected;
  final int totalClasses;
  final DateTime paymentDate;
  final DateTime startDate;
  final DateTime endDate;
  final Widget? child; // Add optional child parameter
  final void Function()? onTap;

  const ClosedStudentCourseCard({
    super.key,
    this.isSelected = false,
    required this.totalClasses,
    required this.paymentDate,
    required this.startDate,
    required this.endDate,
    this.child, // Optional child parameter
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      isSelected: isSelected,
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Completed', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            IconInfoColumn(
              icon: Icons.close_rounded,
              label1: 'Completed',
              label2: timeAgoString(endDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRowClosed(totalClasses, startDate, endDate, context),
            const SizedBox(height: 16), // Space between info and child
            if (child != null)
              child!, // Display the child widget if it's not null
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowClosed(int totalClasses, DateTime startDate,
      DateTime endDate, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InfoColumn(
            value: totalClasses.toString(),
            label: 'Credit',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InfoColumn(
            value: '${endDate.difference(startDate).inDays + 1}',
            label: 'Duration',
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
