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
  final double elevation;
  final bool showBorder;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.padding = const EdgeInsets.all(AppPaddings.smallPadding),
    this.margin = const EdgeInsets.all(AppMargins.smallMargin),
    this.elevation = 2.0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.15),
              blurRadius: 12.0,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.card,
          borderRadius: BorderRadius.circular(12.0),
          elevation: elevation,
          color: theme.cardColor,
          shadowColor: theme.shadowColor,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: showBorder
                  ? (isSelected
                      ? Border.all(
                          color: colorScheme.primary,
                          width: 2.0,
                        )
                      : Border.all(
                          color: theme.dividerColor.withOpacity(0.5),
                          width: 1.0,
                        ))
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: onTap,
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}