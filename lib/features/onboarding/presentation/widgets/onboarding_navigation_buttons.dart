import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class OnboardingNavigationButton extends StatelessWidget {
  const OnboardingNavigationButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon = Icons.arrow_forward_rounded,
    this.alignment = Alignment.center,
    this.width,
    this.padding,
    this.borderRadius,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? trailingIcon;
  final Alignment alignment;
  final double? width;
  final EdgeInsets? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: width,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          foregroundColor: AppColors.buttonText,
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppTextStyles.buttonText),
            if (trailingIcon != null) ...[
              SizedBox(width: 4.w),
              Icon(trailingIcon, color: AppColors.buttonText, size: 18.w),
            ],
          ],
        ),
      ),
    );

    if (alignment == Alignment.center) {
      return button;
    }

    return Align(alignment: alignment, child: button);
  }
}
