import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';

/// Widget displaying callback requested state
class CallbackRequestedState extends StatelessWidget {
  const CallbackRequestedState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 354.w,
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Phone call icon and text
          Column(
            children: [
              // Phone call illustration
              Image.asset(
                'assets/images/callback.png',
                width: 125.w,
                height: 104.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 14.h),

              // Callback requested title
              Text(
                l10n.orders_callback_state_title,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w700,
                  fontSize: 21.sp,
                  height: 1.149, // lineHeight: 1.1490000770205544em from Figma
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14.h),

              // Callback requested description
              SizedBox(
                width: 302.w,
                child: Text(
                  l10n.orders_callback_state_subtitle,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    height: 1.3, // lineHeight: 1.2999999523162842em from Figma
                    color: AppColors.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
