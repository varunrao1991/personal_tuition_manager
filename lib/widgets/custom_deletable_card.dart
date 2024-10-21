import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'custom_card.dart';

class CustomDeletableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback onDelete;
  final bool isSelected;

  const CustomDeletableCard({
    super.key,
    required this.child,
    this.onTap,
    required this.onDelete,
    this.isSelected = false,
  });

  @override
  _CustomDeletableCardState createState() => _CustomDeletableCardState();
}

class _CustomDeletableCardState extends State<CustomDeletableCard> {
  double _dragExtent = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const maxDragRatio = 0.3;
      final maxDrag = constraints.maxWidth * maxDragRatio;

      final theme = Theme.of(context);
      final swipeLeftColor = theme.colorScheme.error;
      const margin = EdgeInsets.all(AppMargins.mediumMargin);
      const marginDelete = EdgeInsets.fromLTRB(100.0, AppMargins.mediumMargin,
          AppMargins.mediumMargin, AppMargins.mediumMargin);

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: marginDelete,
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
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx < 0) {
                  setState(() {
                    _dragExtent += details.delta.dx;
                    _dragExtent = _dragExtent.clamp(-maxDrag, maxDrag);
                  });
                }
              },
              onHorizontalDragEnd: (details) {
                if (_dragExtent.abs() >= maxDrag * 0.5) {
                  if (_dragExtent < 0) {
                    widget.onDelete();
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
