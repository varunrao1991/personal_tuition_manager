import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../utils/time_ago.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/icon_info_column.dart';
import '../../../widgets/info_column.dart';

class OngoingCourseCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime paymentDate;
  final int totalClasses;
  final int completedDays;
  final Widget? child;
  final VoidCallback? onTap;

  const OngoingCourseCard({
    super.key,
    required this.startDate,
    required this.paymentDate,
    required this.totalClasses,
    required this.completedDays,
    this.child, // Optional child parameter
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ongoing course",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                IconInfoColumn(
                  icon: Icons.access_time,
                  label1: 'Started',
                  label2: timeAgoString(startDate),
                ),
                const SizedBox(height: 8),
                _buildInfo(),
                const SizedBox(height: 4),
                if (child != null) child!,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    int remainingClasses =
        (totalClasses - completedDays).clamp(0, totalClasses);
    int completedValue =
        completedDays >= totalClasses ? totalClasses : completedDays;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: InfoColumn(
              value: completedValue.toString(),
              label: 'Completed',
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InfoColumn(
              value: remainingClasses.toString(),
              label: 'Remaining',
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InfoColumn(
              value: totalClasses.toString(),
              label: 'Credit',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
