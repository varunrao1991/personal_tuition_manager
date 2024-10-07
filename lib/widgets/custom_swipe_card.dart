import 'package:flutter/material.dart';

class CustomSwipeCard extends StatefulWidget {
  final Widget child;
  final double elevation;
  final double borderRadius;
  final VoidCallback? onTap; // Add a callback for tap functionality
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const CustomSwipeCard({
    super.key,
    required this.child,
    this.elevation = 4.0,
    this.borderRadius = 15.0,
    this.onTap, // Include the onTap parameter
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  _CustomSwipeCardState createState() => _CustomSwipeCardState();
}

class _CustomSwipeCardState extends State<CustomSwipeCard> {
  double _dragExtent = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const maxDragRatio = 0.3;
          final maxDrag = constraints.maxWidth * maxDragRatio;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Background container with left and right actions
              Positioned.fill(
                child: Row(
                  children: [
                    // Left Swipe Action (Edit)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(15.0),
                          ),
                          color: Colors.blueAccent,
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    // Right Swipe Action (Delete)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(15.0),
                          ),
                          color: Colors.redAccent,
                        ),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // The actual card with draggable behavior and tap functionality
              GestureDetector(
                onTap: widget.onTap, // Trigger the onTap callback
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragExtent += details.delta.dx * maxDragRatio;
                    _dragExtent = _dragExtent.clamp(-maxDrag, maxDrag);
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (_dragExtent.abs() >= maxDrag * 0.5) {
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
                child: Transform.translate(
                  offset: Offset(_dragExtent, 0),
                  child: Card(
                    elevation: widget.elevation,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                    child: widget.child, // The content of the card
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
