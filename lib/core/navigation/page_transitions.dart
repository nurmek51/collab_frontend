import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../animations/animations.dart';

class AppPageTransitions {
  AppPageTransitions._();

  static CustomTransitionPage<T> slideTransition<T extends Object?>({
    required Widget child,
    required LocalKey key,
    SlideDirection direction = SlideDirection.right,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration ?? AnimationConstants.pageTransition,
      reverseTransitionDuration: duration ?? AnimationConstants.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation =
            Tween<Offset>(
              begin: _getBeginOffset(direction),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: AnimationConstants.defaultCurve,
              ),
            );

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.defaultCurve,
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  static CustomTransitionPage<T> fadeTransition<T extends Object?>({
    required Widget child,
    required LocalKey key,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration ?? AnimationConstants.pageTransition,
      reverseTransitionDuration: duration ?? AnimationConstants.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AnimationConstants.defaultCurve,
          ),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<T> scaleTransition<T extends Object?>({
    required Widget child,
    required LocalKey key,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration ?? AnimationConstants.pageTransition,
      reverseTransitionDuration: duration ?? AnimationConstants.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: AnimationConstants.elasticCurve,
          ),
        );

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.defaultCurve,
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  static CustomTransitionPage<T> bottomSheetTransition<T extends Object?>({
    required Widget child,
    required LocalKey key,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration ?? AnimationConstants.medium,
      reverseTransitionDuration: duration ?? AnimationConstants.medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return SlideTransition(position: slideAnimation, child: child);
      },
    );
  }

  static Offset _getBeginOffset(SlideDirection direction) {
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
}
