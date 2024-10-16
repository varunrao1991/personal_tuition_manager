import 'package:flutter/material.dart';
import '../../../utils/time_ago.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_swipe_card.dart';
import '../../../widgets/icon_info_column.dart';
import '../../../widgets/info_column.dart';

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
    return CustomSwipeCard(
      onTap: onTap,
      onSwipeLeft: onDelete,
      onSwipeRight: onEdit,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStudentName(context),
                const SizedBox(height: 8),
                IconInfoColumn(
                  icon: Icons.access_time,
                  label1: 'Started',
                  label2: timeAgoString(startDate),
                ),
                const SizedBox(height: 8),
                _buildInfo(),
                const SizedBox(height: 8),
                _buildButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentName(BuildContext context) {
    return Row(
      children: [
        Text(name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(width: 4),
        if (noCredit == false)
          const Icon(
            Icons.check,
            color: Colors.green,
          ),
      ],
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

  Widget _buildButtons() {
    int remainingClasses =
        (totalClasses - completedDays).clamp(0, totalClasses);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildButton('Restart', onUpdate),
        const SizedBox(width: 16),
        _buildButton('Close', remainingClasses == 0 ? onClose : null),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed) {
    return Expanded(
      child: CustomElevatedButton(
        text: text,
        onPressed: onPressed,
      ),
    );
  }
}
