import 'package:flutter/material.dart';

class AnimationConstants {
  AnimationConstants._();

  // Duration constants - optimized for smooth, natural feel
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 400);

  // Curve constants - all using smooth, natural easing
  static const Curve smoothCurve = Curves.easeInOutQuart;
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve gentleCurve = Curves.easeOutCubic;
  static const Curve bounceGentle = Curves.elasticOut;
  static const Curve entranceCurve = Curves.easeOutBack;
  static const Curve elasticCurve = Curves.elasticOut;

  // Scale constants - subtle and smooth
  static const double defaultScale = 0.98;
  static const double buttonPressScale = 0.96;
  static const double cardHoverScale = 1.01;
  static const double iconActiveScale = 1.08;
  static const double tabBarScale = 1.02;

  // Opacity constants
  static const double disabledOpacity = 0.6;
  static const double hoverOpacity = 0.8;

  // Layout constants
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const double defaultBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double cardBorderRadius = 20.0;

  // Animation timing offsets for staggered animations
  static Duration getStaggerDelay(int index, {int baseDelay = 50}) {
    return Duration(milliseconds: index * baseDelay);
  }
}
