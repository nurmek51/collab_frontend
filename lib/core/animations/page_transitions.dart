import 'package:flutter/material.dart';
import 'animation_constants.dart';

class SlidePageTransition extends PageRouteBuilder {
  final Widget child;
  final SlideDirection direction;
  final Duration? duration;

  SlidePageTransition({
    required this.child,
    this.direction = SlideDirection.right,
    this.duration,
  }) : super(
         transitionDuration: duration ?? AnimationConstants.pageTransition,
         reverseTransitionDuration:
             duration ?? AnimationConstants.pageTransition,
         pageBuilder: (context, animation, secondaryAnimation) => child,
       );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offsetAnimation =
        Tween<Offset>(begin: _getBeginOffset(), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            curve: AnimationConstants.defaultCurve,
          ),
        );

    final secondaryOffsetAnimation =
        Tween<Offset>(begin: Offset.zero, end: _getSecondaryOffset()).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: AnimationConstants.defaultCurve,
          ),
        );

    return SlideTransition(
      position: offsetAnimation,
      child: SlideTransition(position: secondaryOffsetAnimation, child: child),
    );
  }

  Offset _getBeginOffset() {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(-1.0, 0.0);
      case SlideDirection.right:
        return const Offset(1.0, 0.0);
      case SlideDirection.up:
        return const Offset(0.0, -1.0);
      case SlideDirection.down:
        return const Offset(0.0, 1.0);
    }
  }

  Offset _getSecondaryOffset() {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(1.0, 0.0);
      case SlideDirection.right:
        return const Offset(-1.0, 0.0);
      case SlideDirection.up:
        return const Offset(0.0, 1.0);
      case SlideDirection.down:
        return const Offset(0.0, -1.0);
    }
  }
}

class FadePageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration? duration;

  FadePageTransition({required this.child, this.duration})
    : super(
        transitionDuration: duration ?? AnimationConstants.pageTransition,
        reverseTransitionDuration:
            duration ?? AnimationConstants.pageTransition,
        pageBuilder: (context, animation, secondaryAnimation) => child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: AnimationConstants.defaultCurve,
      ),
      child: child,
    );
  }
}

class ScalePageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration? duration;

  ScalePageTransition({required this.child, this.duration})
    : super(
        transitionDuration: duration ?? AnimationConstants.pageTransition,
        reverseTransitionDuration:
            duration ?? AnimationConstants.pageTransition,
        pageBuilder: (context, animation, secondaryAnimation) => child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: AnimationConstants.elasticCurve,
      ),
      child: child,
    );
  }
}

enum SlideDirection { left, right, up, down }
