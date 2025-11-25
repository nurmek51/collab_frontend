import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';

/// Widget for adding another order
class AddOrderButton extends StatelessWidget {
  const AddOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        context.push('/new-order');
      },
      child: Container(
        width: 354.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/svgs/add_icon.svg',
              width: 16.w,
              height: 16.h,
            ),
            Text(
              '  ${l10n.orders_waiting_state_new_button}',
              style: AppTextStyles.addOrderText,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for adding new project (when there are active orders)
class AddProjectButton extends StatelessWidget {
  const AddProjectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/new-order');
      },
      child: Container(
        width: 354.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svgs/add_icon.svg',
              width: 16.w,
              height: 16.h,
            ),
            Text('  Новый проект', style: AppTextStyles.addOrderText),
          ],
        ),
      ),
    );
  }
}
