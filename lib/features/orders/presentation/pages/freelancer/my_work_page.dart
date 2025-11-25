import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/widgets/freelancer_flow_exports.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/api/applications_api.dart';
import '../../../../../shared/api/orders_api.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../../features/auth/presentation/widgets/gradient_background.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/order_details_model.dart';

/// "My Work" page showing freelancer's responses and active projects
class MyWorkPage extends StatefulWidget {
  const MyWorkPage({super.key});

  @override
  State<MyWorkPage> createState() => _MyWorkPageState();
}

class _MyWorkPageState extends State<MyWorkPage> with FreelancerPageMixin {
  late final ApplicationsApi _applicationsApi;
  late final OrdersApi _ordersApi;
  late final ScrollController _scrollController;
  bool isLoading = true;
  String? error;
  List<ApplicationModel> applications = [];
  List<ApplicationModel> activeProjects = [];
  Map<String, String> orderTitles = {}; // orderId -> orderTitle
  bool showResponsesEmptyState = false;

  @override
  void initState() {
    super.initState();
    _applicationsApi = sl<ApplicationsApi>();
    _ordersApi = sl<OrdersApi>();
    _scrollController = ScrollController();
    _loadMyWorkData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMyWorkData({bool showLoader = true}) async {
    try {
      if (mounted) {
        setState(() {
          if (showLoader) {
            isLoading = true;
          }
          error = null;
        });
      }

      final allApplications = await _applicationsApi.getMyApplications();

      // Separate active projects (accepted) and responses (pending/rejected)
      final activeProjects = allApplications
          .where((app) => app.status == ApplicationStatus.accepted)
          .toList();
      final hasPendingOrRejected = allApplications.any(
        (app) =>
            app.status == ApplicationStatus.pending ||
            app.status == ApplicationStatus.rejected,
      );
      final responses = allApplications
          .where((app) => app.status != ApplicationStatus.accepted)
          .toList();

      // Fetch order titles for each unique orderId
      final orderIds = allApplications.map((app) => app.orderId).toSet();
      final Map<String, String> titles = {};
      for (final orderId in orderIds) {
        try {
          final orderData = await _ordersApi.getOrderById(orderId);
          final orderDetails = OrderDetailsModel.fromJson(orderData);
          titles[orderId] = orderDetails.orderTitle;
        } catch (e) {
          debugPrint('Failed to load order details for $orderId: $e');
        }
      }

      if (mounted) {
        setState(() {
          applications = responses;
          this.activeProjects = activeProjects;
          orderTitles = titles;
          isLoading = false;
          showResponsesEmptyState = responses.isEmpty && hasPendingOrRejected;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Не удалось загрузить мои работы';
          isLoading = false;
          showResponsesEmptyState = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: SafeArea(
            child: Column(
              children: [
                // Header with title and profile icon
                _buildHeader(),

                // Main content
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : error != null
                      ? _buildErrorState()
                      : RefreshIndicator(
                          onRefresh: _handleRefresh,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Column(
                                children: [
                                  SizedBox(height: 8.h),

                                  // Working Projects section
                                  _buildWorkingProjectsSection(),

                                  SizedBox(height: 24.h),

                                  // Responses section
                                  _buildResponsesSection(),

                                  SizedBox(
                                    height: 100.h,
                                  ), // Space for bottom tab bar
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ошибка загрузки',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 18.sp,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => _loadMyWorkData(),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Моя работа',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w700,
              fontSize: 26.sp,
              height: 1.149,
              color: AppColors.primaryText,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/freelancer-profile'),
            child: Icon(
              Icons.account_circle_outlined,
              size: 29.w,
              color: const Color(0xFF517499),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingProjectsSection() {
    return Container(
      width: 355.w,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title and padding - only show if there are active projects
          if (!activeProjects.isEmpty) ...[
            Text(
              AppLocalizations.of(context)!.my_work_active_projects_title,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w700,
                fontSize: 17.sp,
                height: 1.149,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Content based on state
          if (activeProjects.isEmpty)
            _buildEmptyProjectsState()
          else
            _buildActiveProjectsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyProjectsState() {
    return Column(
      children: [
        // Laptop illustration
        Container(
          width: 181.15.w,
          height: 117.h,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
          child: Image.asset(
            'assets/images/laptop_icon.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.laptop_mac,
                  size: 60.w,
                  color: const Color(0xFF96A4B3),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 8.h),

        // Title
        Text(
          AppLocalizations.of(context)!.my_work_active_projects_title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
            height: 1.149,
            color: AppColors.primaryText,
          ),
        ),

        SizedBox(height: 8.h),

        // Subtitle
        Text(
          AppLocalizations.of(context)!.my_work_active_projects_empty_subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
            height: 1.3,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyResponsesState() {
    return Column(
      children: [
        // Response illustration
        Container(
          width: 181.15.w,
          height: 11.h,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
        ),

        // Empty state message
        Text(
          'Откликов пока нет.\nОткликайтесь на интересные проекты.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
            height: 1.3,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveProjectsList() {
    return Column(
      children: activeProjects
          .map(
            (project) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: _buildActiveProjectItem(project),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActiveProjectItem(ApplicationModel application) {
    return GestureDetector(
      onTap: () {
        // Navigate to project details page
        context.push(
          '/project-details/${application.orderId}',
          extra: {'fromMyWork': true},
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0x0D000000), // rgba(0, 0, 0, 0.05)
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderTitles[application.orderId] ??
                        'Order: ${application.orderId}',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      height: 1.3,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    _getStatusText(application.status),
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      height: 1.3,
                      color: _getStatusColor(application.status),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16.w,
              color: const Color(0xFF96A4B3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesSection() {
    final hasResponses = applications.isNotEmpty;

    // Hide the entire section if there are no responses and no empty state to show
    if (!hasResponses && !showResponsesEmptyState) {
      return const SizedBox.shrink();
    }

    final spacingHeight = (showResponsesEmptyState || !hasResponses)
        ? 12.h
        : 16.h;

    return Container(
      width: 355.w,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            AppLocalizations.of(context)!.my_work_responses_title,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
              height: 1.149,
              color: AppColors.primaryText,
            ),
          ),

          SizedBox(height: spacingHeight),

          if (showResponsesEmptyState)
            _buildEmptyResponsesState()
          else if (hasResponses)
            ...applications.map(
              (application) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: _buildResponseItem(application),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadMyWorkData(showLoader: false);
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildResponseItem(ApplicationModel application) {
    return GestureDetector(
      onTap: () {
        // Navigate to project details page
        context.push(
          '/project-details/${application.orderId}',
          extra: {'fromMyWork': true},
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0x0D000000), // rgba(0, 0, 0, 0.05)
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderTitles[application.orderId] ??
                        'Order: ${application.orderId}',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      height: 1.3,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    _getStatusText(application.status),
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      height: 1.3,
                      color: _getStatusColor(application.status),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16.w,
              color: const Color(0xFF96A4B3),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'На рассмотрении';
      case ApplicationStatus.accepted:
        return 'Принято';
      case ApplicationStatus.rejected:
        return 'Отклонено';
    }
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return const Color(0xFF517499);
      case ApplicationStatus.accepted:
        return const Color(0xFF4DC53A);
      case ApplicationStatus.rejected:
        return const Color(0xFFED6363);
    }
  }
}
