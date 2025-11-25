import 'package:flutter/material.dart';
import 'animation_constants.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration? duration;
  final Curve? curve;
  final double? scale;
  final bool enableHover;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.duration,
    this.curve,
    this.scale,
    this.enableHover = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AnimationConstants.fast,
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: widget.scale ?? AnimationConstants.cardHoverScale,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.curve ?? AnimationConstants.defaultCurve,
          ),
        );

    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? AnimationConstants.defaultCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    if (_isHovered || _isPressed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.enableHover
          ? (_) {
              setState(() => _isHovered = true);
              _updateAnimation();
            }
          : null,
      onExit: widget.enableHover
          ? (_) {
              setState(() => _isHovered = false);
              _updateAnimation();
            }
          : null,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _updateAnimation();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _updateAnimation();
          widget.onTap?.call();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _updateAnimation();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: widget.duration ?? AnimationConstants.fast,
                curve: widget.curve ?? AnimationConstants.defaultCurve,
                decoration: BoxDecoration(),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}
