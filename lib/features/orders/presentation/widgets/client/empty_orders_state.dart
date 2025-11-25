import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';

/// Widget displaying empty orders state for clients with illustration and message
class EmptyOrdersState extends StatelessWidget {
  const EmptyOrdersState({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Empty state illustration and text
          Column(
            children: [
              // Tray illustration
              Image.asset(
                'assets/images/tray_without_docs-7313b2.png',
                width: 138.46.w,
                height: 96.06.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 6.h),
              // Empty state text
              Text(
                AppLocalizations.of(context)!.orders_empty_state_title,
                style: AppTextStyles.emptyStateTitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
