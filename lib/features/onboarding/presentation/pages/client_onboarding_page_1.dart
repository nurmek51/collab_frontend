import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/onboarding_navigation_buttons.dart';
import '../../../../core/widgets/onboarding_wrapper.dart';

class ClientOnboardingPageOne extends StatelessWidget {
  const ClientOnboardingPageOne({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              left: 27.w,
              top: 248.h,
              child: Image.asset(
                'assets/images/collab_logo.png',
                width: 157.58.w,
                height: 34.h,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              left: 28.w,
              top: 324.h,
              child: Container(
                width: 322.w,
                padding: EdgeInsets.fromLTRB(16.w, 0, 0, 0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.profileIconColor,
                      width: 3.w,
                    ),
                  ),
                ),
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.onboardingHeadlineRegular,
                    children: [
                      const TextSpan(text: 'Собираем '),
                      TextSpan(
                        text: 'сильные команды ',
                        style: AppTextStyles.onboardingHeadlineEmphasis,
                      ),
                      const TextSpan(text: 'быстро и без '),
                      TextSpan(
                        text: 'лишних затрат',
                        style: AppTextStyles.onboardingHeadlineEmphasis,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Positioned(
              left: 27.w,
              top: 550.h,
              child: OnboardingNavigationButton(
                label: 'Вперед',
                onPressed: onNext,
                alignment: Alignment.centerLeft,
                trailingIcon: Icons.arrow_forward_rounded,
                borderRadius: 12,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              ),
            ),
            // Positioned(
            //   right: 0,
            //   left: 0,
            //   top: 700.h,
            //   child: Center(
            //     child: TextButton(
            //       onPressed: onSkip,
            //       style: TextButton.styleFrom(
            //         foregroundColor: AppColors.linkColor,
            //         padding: EdgeInsets.zero,
            //         minimumSize: Size.zero,
            //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //         textStyle: AppTextStyles.linkText,
            //       ),
            //       child: Text('Пропустить', style: AppTextStyles.linkText),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
