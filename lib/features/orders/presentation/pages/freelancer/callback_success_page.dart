import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../auth/presentation/widgets/gradient_background.dart';

/// Callback Success page showing confirmation after requesting callback
class CallbackSuccessPage extends StatelessWidget {
  const CallbackSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                width: 354.w,
                padding: EdgeInsets.fromLTRB(43.w, 24.h, 43.w, 34.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(32.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // OK hand emoji
                    Text(
                      '👌🏻',
                      style: TextStyle(
                        fontFamily: 'SF Compact',
                        fontWeight:
                            FontWeight.w800, // Closest to w790 from Figma
                        fontSize: 58.sp,
                        height: 1.193, // lineHeight: 1.193359375em from Figma
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 19.h),

                    // Content section
                    Column(
                      children: [
                        // Title
                        Text(
                          AppLocalizations.of(context)!.callback_success_title,
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w700,
                            fontSize: 21.sp,
                            height:
                                1.149, // lineHeight: 1.1490000770205544em from Figma
                            color: AppColors.primaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 12.h),

                        // Description
                        SizedBox(
                          width: 267.w,
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.callback_success_subtitle,
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              height:
                                  1.3, // lineHeight: 1.2999999523162842em from Figma
                              color: AppColors.primaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 19.h),

                    // Got it button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to My Work page
                          context.go('/my-work');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.callback_success_button,
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w500,
                              fontSize: 17.sp,
                              height:
                                  1.3, // lineHeight: 1.2999999102424173em from Figma
                              color: AppColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
