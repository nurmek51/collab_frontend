import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable separator widget that stretches to full screen width
/// Perfect for visual separation between sections in lists and forms
class FullWidthSeparator extends StatelessWidget {
  /// Height of the separator (default: 60.h)
  final double height;

  /// Path to the SVG asset (default: 'assets/svgs/separator.svg')
  final String svgPath;

  /// Whether to add edge caps if SVG doesn't reach screen edges perfectly
  final bool addEdgeCaps;

  /// Color for edge caps (only used if addEdgeCaps is true)
  final Color? edgeCapColor;

  const FullWidthSeparator({
    super.key,
    this.height = 60.0,
    this.svgPath = 'assets/svgs/separator.svg',
    this.addEdgeCaps = false,
    this.edgeCapColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height.h,
      child: Stack(
        children: [
          // Main separator SVG
          Positioned.fill(
            child: SvgPicture.asset(
              svgPath,
              width: double.infinity,
              height: height.h,
              fit: BoxFit.fitWidth, // Ensures proper width scaling
              alignment: Alignment.center,
            ),
          ),

          // Optional: Add edge caps if SVG doesn't reach perfectly to edges
          if (addEdgeCaps) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 2.w,
              child: Container(
                color:
                    edgeCapColor ??
                    const Color(0xFFADC1C5), // Default separator color
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 2.w,
              child: Container(
                color:
                    edgeCapColor ??
                    const Color(0xFFADC1C5), // Default separator color
              ),
            ),
          ],
        ],
      ),
    );
  }
}
