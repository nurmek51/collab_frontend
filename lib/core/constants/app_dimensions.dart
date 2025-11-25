import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Dimension constants extracted from Figma design
class AppDimensions {
  AppDimensions._();

  // Screen dimensions from Figma (394x853)
  static const double designWidth = 394.0;
  static const double designHeight = 853.0;

  // Button dimensions from Figma
  static double get buttonHeight => 50.h;
  static double get buttonWidth => 322.w;
  static double get buttonBorderRadius => 16.r;

  // Padding and margins from Figma
  static double get horizontalPadding => 36.w;
  static double get verticalPadding => 15.h;

  // Logo dimensions
  static double get logoWidth => 162.21.w;
  static double get logoHeight => 35.h;

  // Page indicator dimensions
  static double get indicatorSize => 8.r;
  static double get indicatorSpacing => 8.w;

  // Border radius
  static double get screenBorderRadius => 24.r;

  // Spacing
  static double get smallSpacing => 8.h;
  static double get mediumSpacing => 16.h;
  static double get largeSpacing => 24.h;
  static double get extraLargeSpacing => 32.h;
}
