import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class ConfirmDeletionModal extends StatelessWidget {
  final VoidCallback onDeletePressed;
  final VoidCallback onCancelPressed;
  final bool isLoading;

  const ConfirmDeletionModal({
    super.key,
    required this.onDeletePressed,
    required this.onCancelPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: GestureDetector(
        onTap: isLoading
            ? null
            : () {
                onCancelPressed();
                Navigator.of(context).pop(false);
              },
        child: Material(
          color: Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: GestureDetector(
              onTap:
                  () {}, // Prevent dismissing when tapping on the modal itself
              child: Container(
                width: MediaQuery.of(context).size.width - 40.w,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon - minus sign in circle
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5757).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/svgs/minus_icon.svg',
                            width: 28.w,
                            height: 28.w,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFFF5757),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Title
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Удалить специализацию?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w500,
                            fontSize: 20.sp,
                            color: AppColors.primaryText,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Buttons
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        onCancelPressed();
                                        Navigator.of(context).pop(false);
                                      },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Отмена',
                                      style: TextStyle(
                                        fontFamily: 'Ubuntu',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.sp,
                                        color: AppColors.primaryText,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Delete button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        onDeletePressed();
                                        Navigator.of(context).pop(true);
                                      },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5757),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    alignment: Alignment.center,
                                    child: isLoading
                                        ? SizedBox(
                                            height: 20.h,
                                            width: 20.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.w,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(AppColors.white),
                                            ),
                                          )
                                        : Text(
                                            'Удалить',
                                            style: TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.sp,
                                              color: AppColors.white,
                                              height: 1.2,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
