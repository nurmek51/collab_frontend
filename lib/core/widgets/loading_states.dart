import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../animations/animations.dart';

class AnimatedLoadingSpinner extends StatefulWidget {
  final double? size;
  final Color? color;
  final Duration? duration;

  const AnimatedLoadingSpinner({
    super.key,
    this.size,
    this.color,
    this.duration,
  });

  @override
  State<AnimatedLoadingSpinner> createState() => _AnimatedLoadingSpinnerState();
}

class _AnimatedLoadingSpinnerState extends State<AnimatedLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size ?? 24.w,
        height: widget.size ?? 24.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: (widget.color ?? Colors.blue).withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border(
              top: BorderSide(color: widget.color ?? Colors.blue, width: 2),
              right: BorderSide.none,
              bottom: BorderSide.none,
              left: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class PulsingDots extends StatefulWidget {
  final int count;
  final Color? color;
  final double? size;
  final Duration? duration;

  const PulsingDots({
    super.key,
    this.count = 3,
    this.color,
    this.size,
    this.duration,
  });

  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.count,
      (index) => AnimationController(
        duration: widget.duration ?? AnimationConstants.slow,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.count, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: widget.size ?? 8.w,
                  height: widget.size ?? 8.h,
                  decoration: BoxDecoration(
                    color: widget.color ?? Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? height;
  final Duration? duration;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height,
    this.duration,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AnimationConstants.medium,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: widget.progress.clamp(0.0, 1.0))
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: AnimationConstants.defaultCurve,
          ),
        );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation =
          Tween<double>(
            begin: _animation.value,
            end: widget.progress.clamp(0.0, 1.0),
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: AnimationConstants.defaultCurve,
            ),
          );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 4.h,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.progressColor ?? Colors.blue,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        },
      ),
    );
  }
}
