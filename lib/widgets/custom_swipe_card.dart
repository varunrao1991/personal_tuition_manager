import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'custom_card.dart';

class CustomSwipeCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool isSelected;

  const CustomSwipeCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.isSelected = false,
  });

  @override
  _CustomSwipeCardState createState() => _CustomSwipeCardState();
}

class _CustomSwipeCardState extends State<CustomSwipeCard> {
  double _dragExtent = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const maxDragRatio = 0.25;
      final maxDrag = constraints.maxWidth * maxDragRatio;

      final theme = Theme.of(context);
      final swipeLeftColor = theme.colorScheme.error;
      final swipeRightColor = theme.colorScheme.primary;
      const margin = EdgeInsets.all(AppMargins.mediumMargin);

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: margin,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12.0),
                      ),
                      color: swipeRightColor,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(Icons.edit,
                            color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: margin,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(12.0),
                      ),
                      color: swipeLeftColor,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Icon(Icons.delete,
                            color: theme.colorScheme.onError),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: CustomCard(
              padding: const EdgeInsets.all(AppPaddings.mediumPadding),
              margin: margin,
              isSelected: widget.isSelected,
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragExtent += details.delta.dx;
                  _dragExtent = _dragExtent.clamp(-maxDrag, maxDrag);
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragExtent.abs() >= maxDrag * 0.8) {
                  if (_dragExtent > 0) {
                    widget.onSwipeRight();
                  } else {
                    widget.onSwipeLeft();
                  }
                }
                setState(() {
                  _dragExtent = 0;
                });
              },
              child: widget.child,
            ),
          ),
        ],
      );
    });
  }
}
