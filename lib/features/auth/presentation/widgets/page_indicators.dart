import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Page indicators widget matching Figma design
class PageIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicators({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppDimensions.indicatorSpacing / 2,
          ),
          width: AppDimensions.indicatorSize,
          height: AppDimensions.indicatorSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentPage
                ? AppColors.activeIndicator.withOpacity(0.8)
                : AppColors.inactiveIndicator,
          ),
        ),
      ),
    );
  }
}
