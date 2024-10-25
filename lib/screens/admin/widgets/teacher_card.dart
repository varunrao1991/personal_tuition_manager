import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/admin/teacher_model.dart';
import '../../../widgets/custom_swipe_card.dart';

class TeacherCard extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  const TeacherCard(
      {super.key,
      required this.teacher,
      required this.onEdit,
      required this.onDelete,
      required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomSwipeCard(
      onSwipeLeft: onDelete,
      onSwipeRight: onEdit,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(teacher.name, style: theme.textTheme.titleLarge),
                const SizedBox(width: 8),
                Icon(
                  teacher.enabled ? Icons.check_circle : Icons.cancel,
                  color: teacher.enabled ? theme.primaryColor : Colors.red,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(teacher.mobile, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
