import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Unified Animation System
/// Ensures all animations across the app follow the same smooth, consistent style
class UnifiedAnimations {
  UnifiedAnimations._();

  /// Standard fade animation
  static Widget fade({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: child,
    );
  }

  /// Standard scale animation
  static Widget scale({
    required Widget child,
    double? beginScale,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedScale(
      scale: 1.0,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: child,
    );
  }

  /// Standard slide animation
  static Widget slide({
    required Widget child,
    Offset? beginOffset,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedSlide(
      offset: Offset.zero,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: child,
    );
  }

  /// Combined slide and fade animation
  static Widget slideFade({
    required Widget child,
    Offset? beginOffset,
    double beginOpacity = 0.7,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: AnimatedSlide(
        offset: Offset.zero,
        duration: duration ?? AnimationConstants.medium,
        curve: curve ?? AnimationConstants.smoothCurve,
        child: child,
      ),
    );
  }

  /// Gentle bounce animation for interactive elements
  static Widget bounce({required Widget child, Duration? duration}) {
    return AnimatedScale(
      scale: 1.0,
      duration: duration ?? AnimationConstants.fast,
      curve: AnimationConstants.bounceGentle,
      child: child,
    );
  }

  /// Smooth container animation for state changes
  static Widget container({
    required Widget child,
    required BoxDecoration beginDecoration,
    required BoxDecoration endDecoration,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedContainer(
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      decoration: endDecoration,
      child: child,
    );
  }

  /// Staggered animation for lists
  static Widget staggered({
    required Widget child,
    required int index,
    Duration? baseDelay,
    Duration? duration,
    Curve? curve,
  }) {
    final delay = AnimationConstants.getStaggerDelay(
      index,
      baseDelay: baseDelay?.inMilliseconds ?? 50,
    );

    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: duration ?? AnimationConstants.medium,
            curve: curve ?? AnimationConstants.smoothCurve,
            child: AnimatedSlide(
              offset: Offset.zero,
              duration: duration ?? AnimationConstants.medium,
              curve: curve ?? AnimationConstants.smoothCurve,
              child: child,
            ),
          );
        }
        return Opacity(opacity: 0, child: child);
      },
    );
  }

  /// Smooth text style animation
  static Widget textStyle({
    required Widget child,
    required TextStyle beginStyle,
    required TextStyle endStyle,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedDefaultTextStyle(
      style: endStyle,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: child,
    );
  }

  /// Smooth rotation animation
  static Widget rotation({
    required Widget child,
    double beginTurns = 0.0,
    double endTurns = 0.0,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedRotation(
      turns: endTurns,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: child,
    );
  }

  /// Smooth padding animation
  static Widget padding({
    required Widget child,
    required EdgeInsetsGeometry beginPadding,
    required EdgeInsetsGeometry endPadding,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedPadding(
      padding: endPadding,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: child,
    );
  }

  /// Smooth alignment animation
  static Widget alignment({
    required Widget child,
    required AlignmentGeometry beginAlignment,
    required AlignmentGeometry endAlignment,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedAlign(
      alignment: endAlignment,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: child,
    );
  }

  /// Combined entrance animation (scale + fade + slide)
  static Widget entrance({
    required Widget child,
    Offset? slideOffset,
    double beginScale = 0.8,
    double beginOpacity = 0.0,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: AnimatedScale(
        scale: 1.0,
        duration: duration ?? AnimationConstants.medium,
        curve: curve ?? AnimationConstants.entranceCurve,
        child: AnimatedSlide(
          offset: Offset.zero,
          duration: duration ?? AnimationConstants.medium,
          curve: curve ?? AnimationConstants.smoothCurve,
          child: child,
        ),
      ),
    );
  }

  /// Smooth position animation
  static Widget position({
    required Widget child,
    required Offset beginOffset,
    required Offset endOffset,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedSlide(
      offset: endOffset,
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: child,
    );
  }

  /// Smooth size animation
  static Widget size({
    required Widget child,
    required Size beginSize,
    required Size endSize,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedSize(
      duration: duration ?? AnimationConstants.medium,
      curve: curve ?? AnimationConstants.smoothCurve,
      child: SizedBox(
        width: endSize.width,
        height: endSize.height,
        child: child,
      ),
    );
  }
}

/// Extension methods for easy animation application
extension AnimationExtensions on Widget {
  /// Apply fade animation
  Widget withFade({Duration? duration, Curve? curve}) {
    return UnifiedAnimations.fade(
      child: this,
      duration: duration,
      curve: curve,
    );
  }

  /// Apply scale animation
  Widget withScale({double? beginScale, Duration? duration, Curve? curve}) {
    return UnifiedAnimations.scale(
      child: this,
      beginScale: beginScale,
      duration: duration,
      curve: curve,
    );
  }

  /// Apply slide animation
  Widget withSlide({Offset? beginOffset, Duration? duration, Curve? curve}) {
    return UnifiedAnimations.slide(
      child: this,
      beginOffset: beginOffset,
      duration: duration,
      curve: curve,
    );
  }

  /// Apply slide and fade animation
  Widget withSlideFade({
    Offset? beginOffset,
    double beginOpacity = 0.7,
    Duration? duration,
    Curve? curve,
  }) {
    return UnifiedAnimations.slideFade(
      child: this,
      beginOffset: beginOffset,
      beginOpacity: beginOpacity,
      duration: duration,
      curve: curve,
    );
  }

  /// Apply bounce animation
  Widget withBounce({Duration? duration}) {
    return UnifiedAnimations.bounce(child: this, duration: duration);
  }

  /// Apply entrance animation
  Widget withEntrance({
    Offset? slideOffset,
    double beginScale = 0.8,
    double beginOpacity = 0.0,
    Duration? duration,
    Curve? curve,
  }) {
    return UnifiedAnimations.entrance(
      child: this,
      slideOffset: slideOffset,
      beginScale: beginScale,
      beginOpacity: beginOpacity,
      duration: duration,
      curve: curve,
    );
  }
}
