import 'package:flutter/material.dart';
import '../../../models/student_model.dart';
import '../../../widgets/custom_swipe_card.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentCard({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomSwipeCard(
      onSwipeLeft: onDelete,
      onSwipeRight: onEdit,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
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
      ),
    );
  }
}
