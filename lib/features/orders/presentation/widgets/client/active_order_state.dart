import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../../../../shared/api/companies_api.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../../shared/utils/deep_link_utils.dart';
import '../../../domain/entities/order.dart';

/// Widget displaying active order with project details for clients
class ActiveOrderState extends StatefulWidget {
  final Order order;

  const ActiveOrderState({super.key, required this.order});

  @override
  State<ActiveOrderState> createState() => _ActiveOrderStateState();
}

class _ActiveOrderStateState extends State<ActiveOrderState> {
  String? _companyName;
  String? _companyLogo;
  bool _isLoadingCompany = false;
  late final CompaniesApi _companiesApi;

  @override
  void initState() {
    super.initState();
    _companiesApi = sl<CompaniesApi>();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    if (widget.order.companyId == null) return;

    setState(() {
      _isLoadingCompany = true;
    });

    try {
      final companyData = await _companiesApi.getCompanyById(
        widget.order.companyId!,
      );
      if (mounted) {
        setState(() {
          if (companyData != null) {
            _companyName = companyData['company_name'] as String?;
            _companyLogo = companyData['company_logo'] as String?;
          }
          _isLoadingCompany = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCompany = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _companyName ?? widget.order.title;

    return GestureDetector(
      onTap: () {
        context.push('${AppRouter.clientOrderDetailsRoute}/${widget.order.id}');
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
                // Company name
                Expanded(
                  child: _isLoadingCompany
                      ? Container(
                          height: 20.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrayBackground,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        )
                      : Text(
                          displayName.isNotEmpty ? displayName : 'Проект',
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
                  child: _companyLogo != null
                      ? Image.network(
                          _companyLogo!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultLogo(),
                        )
                      : _buildDefaultLogo(),
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
                      '${AppRouter.clientOrderDetailsRoute}/${widget.order.id}',
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

  Widget _buildDefaultLogo() {
    return Container(
      color: AppColors.lightGrayBackground,
      child: const Icon(Icons.business, color: AppColors.profileIconColor),
    );
  }

  Widget _buildActionsGrid() {
    final bool hasContracts = widget.order.hasContracts;
    final String? chatLink = widget.order.telegramChatLink;
    final bool hasChatLink = chatLink != null && chatLink.isNotEmpty;

    if (!hasContracts) {
      return Center(
        child: _buildWorkingChatCard(
          chatLink: chatLink,
          hasChatLink: hasChatLink,
          width: 314.w,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionCard(
          icon: _buildDocumentIcon(),
          title: 'Документы',
          onTap: () {
            context.push(
              '${AppRouter.clientDocumentsRoute}/${widget.order.id}',
            );
          },
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
        width: 24.w,
        height: 24.h,
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
        child: Icon(
          Icons.description_outlined,
          size: 18.sp,
          color: AppColors.white,
        ),
      ),
    );
  }
}
