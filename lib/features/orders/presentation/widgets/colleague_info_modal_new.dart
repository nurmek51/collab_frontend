import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/freelancer_model.dart';
import '../../data/models/order_details_model.dart';

/// Bottom modal displaying detailed colleague information matching Figma design
class ColleagueInfoModal extends StatelessWidget {
  final FreelancerModel colleague;
  final OrderDetailsModel? orderDetails;
  final VoidCallback onMessageTap;

  const ColleagueInfoModal({
    super.key,
    required this.colleague,
    this.orderDetails,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 853.h,
      width: 394.w,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Stack(
        children: [
          // Background gradient starting from y: 55
          Positioned(
            top: 55.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(-1, -1), // -45 degrees
                  end: Alignment(1, 1),
                  colors: [
                    Color(0xFFBBEBF5), // rgba(187, 235, 245, 1)
                    Color(0xFFFFE7E1), // rgba(255, 231, 225, 1)
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 71.h,
            right: 14.w,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30.w,
                height: 30.h,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 20.w, color: Colors.black),
              ),
            ),
          ),

          // Profile image
          Positioned(
            top: 117.5.h,
            left: 122.5.w,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD9D9D9),
              ),
              child: ClipOval(
                child: colleague.avatarUrl != null
                    ? Image.network(
                        colleague.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
          ),

          // Name - centered with exact positioning
          Positioned(
            top: 285.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                colleague.fullName,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp,
                  height: 1.149,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),

          // Role - centered
          Positioned(
            top: 324.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                colleague.specializationWithLevel,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 17.sp,
                  height: 1.3,
                  color: const Color(0xFF517499),
                ),
              ),
            ),
          ),

          // Salary - centered
          Positioned(
            top: 357.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _getColleagueSalary(),
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  fontSize: 17.sp,
                  height: 1.3,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),

          // Separator 1 - using FullWidthSeparator pattern
          Positioned(
            top: 379.h,
            left: 0,
            child: Container(
              width: 394.w,
              height: 60.h,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Center(
                child: Container(
                  width: 354.w,
                  height: 1.h,
                  color: const Color(0x1A000000),
                ),
              ),
            ),
          ),

          // Description section
          Positioned(
            top: 430.h,
            left: 20.w,
            child: SizedBox(
              width: 354.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 354.w,
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Text(
                      colleague.bio?.isNotEmpty == true
                          ? colleague.bio!
                          : 'Обычно Девы очень спокойны и уравновешенны, но из этого состояния их легко выводят проявления вульгарности, грубости и глупости. Сталкиваясь с ними, Девы как будто теряют привычную систему координат.',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        height: 1.3,
                        color: AppColors.primaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),

          // // Separator 2 - using FullWidthSeparator pattern
          // Positioned(
          //   top: 572.h,
          //   left: 0,
          //   child: Container(
          //     width: 394.w,
          //     height: 60.h,
          //     padding: EdgeInsets.symmetric(vertical: 18.h),
          //     child: Center(
          //       child: Container(
          //         width: 354.w,
          //         height: 1.h,
          //         color: const Color(0x1A000000),
          //       ),
          //     ),
          //   ),
          // ),

          // // Payment history section
          // Positioned(
          //   top: 632.h,
          //   left: 20.w,
          //   child: SizedBox(
          //     width: 354.w,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(16.r),
          //       ),
          //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Expanded(
          //             child: Text(
          //               'История выплат',
          //               style: TextStyle(
          //                 fontFamily: 'Ubuntu',
          //                 fontWeight: FontWeight.w400,
          //                 fontSize: 16.sp,
          //                 height: 1.3,
          //                 color: AppColors.primaryText,
          //               ),
          //             ),
          //           ),
          //           Icon(
          //             Icons.arrow_forward_ios,
          //             size: 16.w,
          //             color: const Color(0xFFA9B6B9),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // // Rate specialist text
          // Positioned(
          //   top: 776.h,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: GestureDetector(
          //       onTap: () {
          //         // TODO: Implement rating functionality
          //       },
          //       child: Text(
          //         'Оценить специалиста',
          //         style: TextStyle(
          //           fontFamily: 'Ubuntu',
          //           fontWeight: FontWeight.w400,
          //           fontSize: 16.sp,
          //           height: 1.3,
          //           color: const Color(0xFF517499),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFD9D9D9),
      child: Icon(Icons.person, size: 75.w, color: AppColors.primaryText),
    );
  }

  /// Get colleague salary from order details or return default
  String _getColleagueSalary() {
    if (orderDetails?.orderSpecializations != null) {
      // Find matching specialization in order
      for (final spec in orderDetails!.orderSpecializations) {
        if (spec.specialization ==
            colleague.specializationsWithLevels.first.specialization) {
          String payPer = spec.conditions.payPer;
          double salary = spec.conditions.salary;

          String period = payPer == 'hour'
              ? '/час'
              : payPer == 'month'
              ? '/мес'
              : payPer == 'project'
              ? '/проект'
              : '';

          return '${_formatCurrency(salary)}$period';
        }
      }
    }

    // Default fallback
    return '10 000 ₸/час';
  }

  /// Format currency with spaces as thousands separator
  String _formatCurrency(double amount) {
    String formatted = amount.toStringAsFixed(0);
    String result = '';
    int count = 0;

    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result = ' $result';
      }
      result = '${formatted[i]}$result';
      count++;
    }

    return '$result ₸';
  }
}
