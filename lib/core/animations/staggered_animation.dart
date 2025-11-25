import 'package:flutter/material.dart';
import 'animation_constants.dart';

class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration? itemDelay;
  final Duration? duration;
  final Curve? curve;
  final bool slideFromBottom;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDelay,
    this.duration,
    this.curve,
    this.slideFromBottom = true,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.duration ?? AnimationConstants.medium,
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: widget.curve ?? AnimationConstants.defaultCurve,
        ),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: widget.slideFromBottom
            ? const Offset(0.0, 0.3)
            : const Offset(0.0, -0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: widget.curve ?? AnimationConstants.defaultCurve,
        ),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    final delay = widget.itemDelay ?? const Duration(milliseconds: 100);

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * delay.inMilliseconds), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimations[index],
              child: SlideTransition(
                position: _slideAnimations[index],
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}
