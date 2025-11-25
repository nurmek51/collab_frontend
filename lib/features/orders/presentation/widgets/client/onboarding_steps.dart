import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';

/// Widget displaying onboarding steps for creating orders
class OnboardingSteps extends StatelessWidget {
  const OnboardingSteps({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 351.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step 1
          _buildStep(
            stepNumber: '1',
            stepIcon: SvgPicture.asset(
              'assets/svgs/step1.svg',
              width: 27.w,
              height: 28.h,
              colorFilter: ColorFilter.mode(
                AppColors.stepNumberColor,
                BlendMode.srcIn,
              ),
            ),
            stepText: l10n.orders_onboarding_step_1,
          ),
          SizedBox(height: 12.h),

          // Step 2
          _buildStep(
            stepNumber: '2',
            stepIcon: SvgPicture.asset(
              'assets/svgs/step2.svg',
              width: 27.w,
              height: 27.h,
              colorFilter: ColorFilter.mode(
                AppColors.stepNumberColor,
                BlendMode.srcIn,
              ),
            ),
            stepText: l10n.orders_onboarding_step_2,
          ),
          SizedBox(height: 12.h),

          // Step 3
          _buildStep(
            stepNumber: '3',
            stepIcon: SvgPicture.asset(
              'assets/svgs/step3.svg',
              width: 27.w,
              height: 28.h,
              colorFilter: ColorFilter.mode(
                AppColors.stepNumberColor,
                BlendMode.srcIn,
              ),
            ),
            stepText: l10n.orders_onboarding_step_3,
          ),
          SizedBox(height: 12.h),

          // Step 4
          _buildStep(
            stepNumber: '4',
            stepIcon: SvgPicture.asset(
              'assets/svgs/step4.svg',
              width: 27.w,
              height: 28.h,
              colorFilter: ColorFilter.mode(
                AppColors.stepNumberColor,
                BlendMode.srcIn,
              ),
            ),
            stepText: l10n.orders_onboarding_step_4,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String stepNumber,
    required Widget stepIcon,
    required String stepText,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Step icon
          Container(
            width: 28.w,
            height: 28.h,
            alignment: Alignment.center,
            child: stepIcon,
          ),
          SizedBox(width: 10.w),

          // Step text
          Expanded(child: Text(stepText, style: AppTextStyles.stepText)),
        ],
      ),
    );
  }
}
