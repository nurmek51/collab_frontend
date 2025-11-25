import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Widget displaying project monthly cost summary
class ProjectSummaryCard extends StatelessWidget {
  final double monthlyTotal;

  const ProjectSummaryCard({super.key, required this.monthlyTotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.w, 16.h, 0.w, 0.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'За месяц (предварительно):',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            '${_formatNumber(monthlyTotal)} ₸',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }
}
