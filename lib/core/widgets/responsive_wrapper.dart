import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'debug_overlay.dart';

/// Responsive wrapper that properly handles flutter_screenutil on web.
///
/// The core issue: flutter_screenutil calculates .w and .h based on actual
/// screen width at initialization. On web with wide viewports, it calculates
/// all sizes proportionally to the full width (e.g., 837px), causing all
/// responsive units to be oversized.
///
/// Solution: Use a MediaQuery override that reports a SMALLER screen size
/// to flutter_screenutil BEFORE it calculates dimensions. This forces
/// screenutil to calculate all .w/.h values as if the screen is 394px wide,
/// preventing stretching.
class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  // Breakpoint: switch to centered layout above this width
  static const double _breakpoint = 440;

  // Fixed mobile design width - must match ScreenUtilInit designSize
  static const double _mobileWidth = 394;
  static const double _mobileHeight = 844;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile layout: viewport width <= 440px
        if (constraints.maxWidth <= _breakpoint) {
          return ScreenUtilInit(
            designSize: const Size(_mobileWidth, _mobileHeight),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) => DebugOverlay(child: this.child),
          );
        }

        // Desktop/tablet layout: viewport width > 440px
        //
        // Critical: Use dynamic designSize matching the actual screen size
        // to force scaleWidth = screenWidth / screenWidth = 1.0
        // This prevents .w/.h from scaling up on wide screens.
        //
        // Why this works:
        // - flutter_screenutil calculates .w = value * (screenWidth / designWidth)
        // - By setting designWidth = screenWidth, scale = 1.0
        // - .w values remain at their intended design sizes
        // - The Container constrains the total width to 394px
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: _mobileWidth,
            child: ScreenUtilInit(
              designSize: Size(constraints.maxWidth, constraints.maxHeight),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) => DebugOverlay(child: this.child),
            ),
          ),
        );
      },
    );
  }
}
