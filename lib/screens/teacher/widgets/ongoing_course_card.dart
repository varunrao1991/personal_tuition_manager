import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../utils/time_ago.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_swipe_card.dart';

class OngoingCourseCard extends StatelessWidget {
  final DateTime startDate;
  final String name;
  final DateTime paymentDate;
  final int totalClasses;
  final int completedDays;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback onClose;
  final VoidCallback? onTap;
  final bool? noCredit;

  const OngoingCourseCard({
    super.key,
    required this.startDate,
    required this.name,
    required this.paymentDate,
    required this.totalClasses,
    required this.completedDays,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdate,
    required this.onClose,
    this.onTap,
    this.noCredit,
  });

  @override
  Widget build(BuildContext context) {
    final remainingClasses =
        (totalClasses - completedDays).clamp(0, totalClasses);
    final progress = completedDays / totalClasses;
    final isCompleted = remainingClasses == 0;

    return CustomSwipeCard(
      onTap: onTap,
      onSwipeLeft: onDelete,
      onSwipeRight: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              if (noCredit == false)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Credit',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Course duration info
          Text(
            'Started ${timeAgoString(startDate)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),

          const SizedBox(height: 16),

          // Progress indicator
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            color: isCompleted
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
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
                value: completedDays.toString(),
                label: 'Completed',
                color: Theme.of(context).colorScheme.primary,
              ),
              _buildStatItem(
                context,
                value: remainingClasses.toString(),
                label: 'Remaining',
                color: remainingClasses == 0 ? Colors.green : Colors.orange,
              ),
              _buildStatItem(
                context,
                value: totalClasses.toString(),
                label: 'Total',
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CustomElevatedButton(
              text: 'Update',
              onPressed: onUpdate,
              icon: Icons.edit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            CustomElevatedButton(
              text: 'Complete',
              icon: isCompleted ? Icons.check_circle : Icons.lock,
              onPressed: isCompleted ? onClose : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
            )
          ])
        ]),
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
