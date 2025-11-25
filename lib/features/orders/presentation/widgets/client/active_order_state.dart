import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../../../../shared/utils/deep_link_utils.dart';
import '../../../domain/entities/order.dart';

/// Widget displaying active order with project details for clients
class ActiveOrderState extends StatelessWidget {
  final Order order;

  const ActiveOrderState({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('${AppRouter.clientOrderDetailsRoute}/${order.id}');
      },
      child: Container(
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
                Expanded(
                  child: Text(
                    order.title.isNotEmpty ? order.title : 'Проект',
                    style: AppTextStyles.projectTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                // Documents and Chat row (using CSS Grid-like layout)
                _buildActionsGrid(),

                SizedBox(height: 13.h),

                // Project information
                GestureDetector(
                  onTap: () {
                    context.push(
                      '${AppRouter.clientOrderDetailsRoute}/${order.id}',
                    );
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
      ),
    );
  }

  Widget _buildActionsGrid() {
    final bool hasDocuments =
        order.documents != null && order.documents!.isNotEmpty;
    final String? chatLink = order.telegramChatLink;
    final bool hasChatLink = chatLink != null && chatLink.isNotEmpty;

    if (!hasDocuments) {
      return Center(
        child: _buildWorkingChatCard(
          chatLink: chatLink,
          hasChatLink: hasChatLink,
          width: 314.w, // Match the width of "information about project" button
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionCard(
          icon: _buildDocumentIcon(),
          title: 'Документы',
          onTap: () {},
        ),
        SizedBox(width: 11.w),
        _buildWorkingChatCard(chatLink: chatLink, hasChatLink: hasChatLink),
      ],
    );
  }

  Widget _buildWorkingChatCard({
    required String? chatLink,
    required bool hasChatLink,
    double? width,
  }) {
    return _buildActionCard(
      icon: Image.asset(
        'assets/images/telegram_icon.png',
        width: 35.w,
        height: 35.h,
        fit: BoxFit.contain,
      ),
      title: 'Рабочий чат',
      onTap: hasChatLink
          ? () async {
              final success = await DeepLinkUtils.openDeepLink(chatLink);
              if (!success) {
                debugPrint('Failed to open work chat link: $chatLink');
              }
            }
          : null,
      isDisabled: !hasChatLink,
      tooltip: !hasChatLink ? 'Chat link not set' : null,
      width: width,
    );
  }

  Widget _buildActionCard({
    required Widget icon,
    required String title,
    required VoidCallback? onTap,
    bool isDisabled = false,
    String? tooltip,
    double? width,
  }) {
    Widget card = GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: width ?? 150.w,
        height: 105.h,
        padding: EdgeInsets.fromLTRB(10.w, 16.h, 10.w, 16.h),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.lightGrayBackground.withValues(alpha: 0.5)
              : AppColors.lightGrayBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(opacity: isDisabled ? 0.5 : 1.0, child: icon),
            SizedBox(height: 14.h),
            Text(
              title,
              style: AppTextStyles.projectActionText.copyWith(
                color: isDisabled
                    ? AppTextStyles.projectActionText.color?.withValues(
                        alpha: 0.5,
                      )
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: card);
    }

    return card;
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
}
