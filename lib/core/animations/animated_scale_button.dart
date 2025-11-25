import 'package:flutter/material.dart';
import 'animation_constants.dart';

class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration? duration;
  final Curve? curve;
  final double? scale;
  final bool enabled;
  final bool hapticFeedback;

  const AnimatedScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.duration,
    this.curve,
    this.scale,
    this.enabled = true,
    this.hapticFeedback = true,
  });

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
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
          end: widget.scale ?? AnimationConstants.buttonPressScale,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.curve ?? AnimationConstants.smoothCurve,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled && !_isPressed) {
      _isPressed = true;
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled && _isPressed) {
      _isPressed = false;
      _controller.reverse();
      widget.onTap?.call();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      _isPressed = false;
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
