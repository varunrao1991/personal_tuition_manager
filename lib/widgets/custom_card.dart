import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final Function(DragEndDetails)? onHorizontalDragEnd;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(AppPaddings.mediumPadding),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: child,
        ),
      ),
    );
  }
}
