import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingWidget extends StatefulWidget {
  const FloatingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
    this.offsetY = 10.0,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final double offsetY;
  final Duration delay;

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Use sine wave for smooth easing at the ends
        final val = math.sin(_controller.value * math.pi / 2);
        return Transform.translate(
          offset: Offset(0, val * widget.offsetY - (widget.offsetY / 2)),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
