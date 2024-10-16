import 'package:flutter/material.dart';
import '../../../utils/time_ago.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/icon_info_column.dart';
import '../../../widgets/info_column.dart';

class ClosedCourseCard extends StatelessWidget {
  final bool isSelected;
  final String name;
  final int totalClasses;
  final DateTime paymentDate;
  final DateTime startDate;
  final DateTime endDate;
  final void Function()? onTap;

  const ClosedCourseCard({
    super.key,
    this.isSelected = false,
    required this.totalClasses,
    required this.name,
    required this.paymentDate,
    required this.startDate,
    required this.endDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      isSelected: isSelected,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          IconInfoColumn(
            icon: Icons.close_rounded,
            label1: 'Completed',
            label2: timeAgoString(endDate),
          ),
          const SizedBox(height: 8),
          _buildInfoRowClosed(totalClasses, startDate, endDate, context),
        ],
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
            value: endDate.difference(startDate).inDays.toString(),
            label: 'Duration',
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
