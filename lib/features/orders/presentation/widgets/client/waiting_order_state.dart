import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/order.dart';

/// Widget displaying waiting for manager response state
class WaitingOrderState extends StatelessWidget {
  final Order? order;

  const WaitingOrderState({super.key, this.order});

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
          // Order created illustration and text
          Column(
            children: [
              // Loop in doc illustration
              Image.asset(
                'assets/images/loop_in_doc-671943.png',
                width: 142.95.w,
                height: 106.5.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 14.h),

              // Order created title
              Text(
                l10n.orders_waiting_state_title,
                style: AppTextStyles.orderCreatedTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14.h),

              // Order created description
              SizedBox(
                width: 302.w,
                child: Text(
                  l10n.orders_waiting_state_subtitle,
                  style: AppTextStyles.orderCreatedDescription,
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
