import 'package:flutter/material.dart';

/// SwipeNavigator for full-screen Instagram-style swipe
class SwipeNavigator extends StatefulWidget {
  final Widget firstPage; // HomeScreen
  final Widget secondPage; // MessengerScreen

  const SwipeNavigator({
    super.key,
    required this.firstPage,
    required this.secondPage,
  });

  @override
  State<SwipeNavigator> createState() => _SwipeNavigatorState();
}

class _SwipeNavigatorState extends State<SwipeNavigator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragStartX = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _isDragging = true;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final delta = details.globalPosition.dx - _dragStartX;

    // Negative delta = swipe left (Home → Messenger)
    double progress = (-delta / screenWidth + _controller.value).clamp(
      0.0,
      1.0,
    );
    _controller.value = progress;
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    const velocityThreshold = 300.0;
    const progressThreshold = 0.3;

    if (_controller.value > progressThreshold ||
        details.primaryVelocity! < -velocityThreshold) {
      _controller.fling(velocity: 1.0); // Complete swipe left → Messenger
    } else if (_controller.value < (1 - progressThreshold) ||
        details.primaryVelocity! > velocityThreshold) {
      _controller.fling(velocity: -1.0); // Swipe back to Home
    } else {
      // Snap to closest side
      if (_controller.value >= 0.5) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final width = MediaQuery.of(context).size.width;
          final slide = width * _controller.value;

          return Stack(
            children: [
              // Messenger slides in from right
              Transform.translate(
                offset: Offset(width - slide, 0),
                child: widget.secondPage,
              ),
              // Home moves out fully (no parallax)
              Transform.translate(
                offset: Offset(-slide, 0),
                child: widget.firstPage,
              ),
            ],
          );
        },
      ),
    );
  }
}
