import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Gradient background widget matching Figma design
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: kIsWeb
            ? null
            : BorderRadius.circular(AppDimensions.screenBorderRadius),
      ),
      child: child,
    );
  }
}
