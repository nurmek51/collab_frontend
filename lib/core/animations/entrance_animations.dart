import 'package:flutter/material.dart';
import 'animation_constants.dart';

class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
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

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AnimationConstants.defaultCurve,
    );

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Offset begin;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.begin = const Offset(0.0, 1.0),
    this.duration,
    this.delay,
    this.curve,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AnimationConstants.medium,
      vsync: this,
    );

    _animation = Tween<Offset>(begin: widget.begin, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? AnimationConstants.defaultCurve,
      ),
    );

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}

class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final double begin;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const ScaleInAnimation({
    super.key,
    required this.child,
    this.begin = 0.0,
    this.duration,
    this.delay,
    this.curve,
  });

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation>
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

    _animation = Tween<double>(begin: widget.begin, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? AnimationConstants.elasticCurve,
      ),
    );

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}
