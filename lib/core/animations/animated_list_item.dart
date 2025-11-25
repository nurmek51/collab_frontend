import 'package:flutter/material.dart';
import 'animation_constants.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? delay;
  final Duration? duration;
  final Curve? curve;
  final bool slideFromBottom;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay,
    this.duration,
    this.curve,
    this.slideFromBottom = true,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AnimationConstants.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? AnimationConstants.defaultCurve,
      ),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: widget.slideFromBottom
              ? const Offset(0.0, 0.3)
              : const Offset(0.0, -0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.curve ?? AnimationConstants.defaultCurve,
          ),
        );

    final delay = widget.delay ?? Duration(milliseconds: widget.index * 100);
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
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
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
