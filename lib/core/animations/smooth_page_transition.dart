import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Optimized smooth page transition for all routes
/// Ultra-smooth, performant fade transition for consistent app experience
class SmoothPageTransition {
  SmoothPageTransition._();

  /// Optimized fade-only transition (fastest and smoothest)
  /// Applied to ALL pages for consistency and performance
  static CustomTransitionPage<T> build<T extends Object?>({
    required Widget child,
    required LocalKey key,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration ?? const Duration(milliseconds: 300),
      reverseTransitionDuration: duration ?? const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Simple, optimized fade curve
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }

  /// Fade transition for tab bar pages (minimal animation)
  static CustomTransitionPage<T> fade<T extends Object?>({
    required Widget child,
    required LocalKey key,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration ?? const Duration(milliseconds: 200),
      reverseTransitionDuration: duration ?? const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Scale + Fade transition for success pages
  static CustomTransitionPage<T> scaleIn<T extends Object?>({
    required Widget child,
    required LocalKey key,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration ?? const Duration(milliseconds: 350),
      reverseTransitionDuration: duration ?? const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
