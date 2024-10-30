import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../utils/time_ago.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_swipe_card.dart';
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
        padding: const EdgeInsets.all(AppPaddings.tinyPadding),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentName(context),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    timeAgoString(startDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(width: 4),
          if (noCredit == false)
            const Icon(
              Icons.check,
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    int remainingClasses =
        (totalClasses - completedDays).clamp(0, totalClasses);
    int completedValue =
        completedDays >= totalClasses ? totalClasses : completedDays;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InfoColumn(
            value: completedValue.toString(),
            mainAxisAlignment: MainAxisAlignment.start,
            label: 'Completed',
            color: Colors.blueAccent,
          ),
        ),
        Expanded(
          child: InfoColumn(
            value: remainingClasses.toString(),
            mainAxisAlignment: MainAxisAlignment.center,
            label: 'Remaining',
            color: Colors.red,
          ),
        ),
        Expanded(
          child: InfoColumn(
            value: totalClasses.toString(),
            mainAxisAlignment: MainAxisAlignment.end,
            label: 'Credit',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    int remainingClasses =
        (totalClasses - completedDays).clamp(0, totalClasses);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildButton('Restart', onUpdate),
        const SizedBox(width: 32),
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
