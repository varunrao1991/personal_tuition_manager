import 'package:flutter/material.dart';
import '../../../utils/time_ago.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/info_column.dart';

class WaitlistCourseCard extends StatelessWidget {
  final int totalClasses;
  final DateTime paymentDate;
  final VoidCallback? onTap;

  const WaitlistCourseCard({
    super.key,
    required this.totalClasses,
    required this.paymentDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.all(AppPaddings.tinyPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yet to start',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Paid ${timeAgoString(paymentDate)}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                InfoColumn(
                  mainAxisAlignment: MainAxisAlignment.start,
                  value: '$totalClasses',
                  label: 'Classes',
                ),
              ],
            )));
  }
}
