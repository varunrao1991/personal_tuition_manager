import 'package:flutter/material.dart';
import 'custom_card.dart';

class CustomDeletableCard extends StatefulWidget {
  final Widget child;
  final double elevation;
  final double borderRadius;
  final VoidCallback? onTap;
  final VoidCallback onDelete;
  final bool isSelected;

  const CustomDeletableCard({
    super.key,
    required this.child,
    this.elevation = 4.0,
    this.borderRadius = 15.0,
    this.onTap,
    required this.onDelete,
    this.isSelected = false,
  });

  @override
  _CustomSwipeCardState createState() => _CustomSwipeCardState();
}

class _CustomSwipeCardState extends State<CustomDeletableCard> {
  double _dragExtent = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const maxDragRatio = 0.3;
          final maxDrag = constraints.maxWidth * maxDragRatio;

          final theme = Theme.of(context);
          final swipeLeftColor = theme.colorScheme.error;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(widget.borderRadius),
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
                  isSelected: widget.isSelected,
                  onTap: widget.onTap,
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragExtent += details.delta.dx;
                      _dragExtent = _dragExtent.clamp(-maxDrag, maxDrag);
                    });
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
        },
      ),
    );
  }
}
