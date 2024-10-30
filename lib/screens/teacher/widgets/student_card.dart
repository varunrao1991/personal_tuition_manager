import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/teacher/student_model.dart';
import '../../../widgets/custom_swipe_card.dart';
import '../../common/thumbnail_loader.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  const StudentCard({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomSwipeCard(
      onSwipeLeft: onDelete,
      onSwipeRight: onEdit,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThumbnailLoader(userId: student.id),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          student.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        student.enabled ? Icons.check_circle : Icons.cancel,
                        color: student.enabled
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onError,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(student.mobile, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
