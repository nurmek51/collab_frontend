import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/order.dart';

/// Widget displaying active order with project details
class ActiveOrderState extends StatelessWidget {
  final Order order;

  const ActiveOrderState({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 355.w,
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 30.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Project header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Project name
              Text(
                order.title.isNotEmpty ? order.title : 'Invictus',
                style: AppTextStyles.projectTitle,
              ),

              // Project logo
              Container(
                width: 34.15.w,
                height: 30.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: order.projectLogo != null
                    ? Image.asset(
                        'assets/images/project_logo-3e4cfa.png',
                        fit: BoxFit.contain,
                      )
                    : Container(
                        color: AppColors.lightGrayBackground,
                        child: const Icon(
                          Icons.business,
                          color: AppColors.profileIconColor,
                        ),
                      ),
              ),
            ],
          ),

          SizedBox(height: 22.h),

          // Project actions
          Column(
            children: [
              // Documents and Chat row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Documents
                  _buildActionCard(
                    icon: _buildDocumentIcon(),
                    title: 'Документы',
                    onTap: () {
                      // TODO: Open documents
                    },
                  ),

                  SizedBox(width: 11.w),

                  // Working chat
                  _buildActionCard(
                    icon: Image.asset(
                      'assets/images/telegram_icon.png',
                      width: 35.w,
                      height: 35.h,
                      fit: BoxFit.contain,
                    ),
                    title: 'Рабочий чат',
                    onTap: () {
                      if (order.telegramChatLink != null &&
                          order.telegramChatLink!.isNotEmpty) {
                        // TODO: Open telegram chat link
                        _openTelegramChat(order.telegramChatLink!);
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: 13.h),

              // Project information
              GestureDetector(
                onTap: () {
                  context.push('/project-info/${order.id}');
                },
                child: Container(
                  width: 314.w,
                  padding: EdgeInsets.fromLTRB(10.w, 16.h, 10.w, 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrayBackground,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Информация о проекте',
                      style: AppTextStyles.projectActionText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        height: 105.h,
        padding: EdgeInsets.fromLTRB(10.w, 16.h, 10.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.lightGrayBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: 14.h),
            Text(
              title,
              style: AppTextStyles.projectActionText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentIcon() {
    return Container(
      width: 35.w,
      height: 35.h,
      decoration: BoxDecoration(
        color: AppColors.orangeAccent,
        borderRadius: BorderRadius.circular(35.r),
      ),
      child: Center(
        child: Text(
          '􀉀',
          style: TextStyle(
            fontFamily: 'SF Compact Rounded',
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
            height: 1.3,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  void _openTelegramChat(String chatLink) {
    // TODO: Implement URL launching for telegram chat
    // This will require url_launcher package
    debugPrint('Opening telegram chat: $chatLink');
  }
}
