import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yoglogonline/widgets/icon_info_column.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_card.dart';

class WaitlistStudentCourseCard extends StatelessWidget {
  final int totalClasses;
  final DateTime paymentDate;
  final VoidCallback? onTap;

  const WaitlistStudentCourseCard({
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
            padding: const EdgeInsets.all(AppPaddings.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yet to start',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(DateFormat('Paid on yyyy-MM-dd').format(paymentDate),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: IconInfoColumn(
                          icon: Icons.date_range,
                          label1: '$totalClasses',
                          label2: 'Total Classes',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
