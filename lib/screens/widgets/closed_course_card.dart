import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/time_ago.dart';
import '../../widgets/custom_card.dart';

class ClosedCourseCard extends StatelessWidget {
  final bool isSelected;
  final String? subjectName;
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
    this.subjectName,
    required this.paymentDate,
    required this.startDate,
    required this.endDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final durationDays = endDate.difference(startDate).inDays + 1;

    return CustomCard(
      onTap: onTap,
      isSelected: isSelected,
      margin: const EdgeInsets.all(AppMargins.mediumMargin),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                if (subjectName != null)
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        subjectName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      )),
                if (subjectName != null) const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completed',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Course completion info
            Text(
              'Completed ${timeAgoString(endDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),

            const SizedBox(height: 16),

            // Progress indicator (showing 100% completion)
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              color: Colors.green,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 12),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  value: totalClasses.toString(),
                  label: 'Total Classes',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                _buildStatItem(
                  context,
                  value: durationDays.toString(),
                  label: 'Duration (days)',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                _buildStatItem(
                  context,
                  value: '100%',
                  label: 'Completion',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}
