import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../animations/animations.dart';

class AnimatedPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const AnimatedPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !isLoading && onPressed != null;

    return AnimatedScaleButton(
      onTap: isEnabled ? onPressed : null,
      enabled: isEnabled,
      child: AnimatedContainer(
        duration: AnimationConstants.medium,
        curve: AnimationConstants.smoothCurve,
        width: double.infinity,
        height: 50.h,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.buttonBackground
              : AppColors.buttonBackground.withOpacity(
                  AnimationConstants.disabledOpacity,
                ),
          borderRadius: BorderRadius.circular(
            borderRadius ?? AnimationConstants.buttonBorderRadius,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.buttonBackground.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: AnimationConstants.medium,
          switchInCurve: AnimationConstants.smoothCurve,
          switchOutCurve: AnimationConstants.smoothCurve,
          child: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.buttonText,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon!,
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      text,
                      style: AppTextStyles.buttonText.copyWith(
                        color: isEnabled
                            ? AppColors.buttonText
                            : AppColors.buttonText.withOpacity(
                                AnimationConstants.disabledOpacity,
                              ),
                      ),
                    ),
                    if (suffixIcon != null) ...[
                      SizedBox(width: 8.w),
                      suffixIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class AnimatedSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? borderColor;
  final Color? textColor;

  const AnimatedSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;

    return AnimatedScaleButton(
      onTap: isEnabled ? onPressed : null,
      enabled: isEnabled,
      child: AnimatedContainer(
        duration: AnimationConstants.medium,
        curve: AnimationConstants.smoothCurve,
        width: double.infinity,
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isEnabled
                ? (borderColor ?? AppColors.black)
                : (borderColor ?? AppColors.black).withOpacity(
                    AnimationConstants.disabledOpacity,
                  ),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(
            AnimationConstants.buttonBorderRadius,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[prefixIcon!, SizedBox(width: 8.w)],
            AnimatedDefaultTextStyle(
              duration: AnimationConstants.fast,
              curve: AnimationConstants.smoothCurve,
              style: AppTextStyles.buttonText.copyWith(
                color: isEnabled
                    ? (textColor ?? AppColors.black)
                    : (textColor ?? AppColors.black).withOpacity(
                        AnimationConstants.disabledOpacity,
                      ),
              ),
              child: Text(text),
            ),
            if (suffixIcon != null) ...[SizedBox(width: 8.w), suffixIcon!],
          ],
        ),
      ),
    );
  }
}

class AnimatedIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final double? size;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onTap: onPressed,
      enabled: onPressed != null,
      child: AnimatedContainer(
        duration: AnimationConstants.medium,
        curve: AnimationConstants.smoothCurve,
        width: size ?? 44.w,
        height: size ?? 44.h,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular((size ?? 44.w) / 2),
          boxShadow: backgroundColor != null
              ? [
                  BoxShadow(
                    color: backgroundColor!.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(child: icon),
      ),
    );
  }
}
