import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final Function(DragEndDetails)? onHorizontalDragEnd;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onLongPress;

  const CustomCard(
      {super.key,
      required this.child,
      this.onTap,
      this.onLongPress,
      this.isSelected = false,
      this.onHorizontalDragUpdate,
      this.onHorizontalDragEnd,
      this.padding = const EdgeInsets.all(AppPaddings.smallPadding),
      this.margin = const EdgeInsets.all(AppMargins.smallMargin)});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: Card(
        margin: margin,
        child: Container(
          padding: padding,
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
