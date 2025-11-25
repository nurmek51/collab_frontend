import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/freelancer_flow_exports.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../../../../shared/api/orders_api.dart';
import '../../../../../shared/api/applications_api.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../../features/auth/presentation/widgets/gradient_background.dart';
import '../../../../../core/animations/animations.dart';

import '../../../data/models/order_feed_model.dart';
import '../../../data/models/application_model.dart';
import '../../widgets/freelancer/order_feed_card.dart';
import '../../widgets/freelancer/vacancy_selection_modal.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with FreelancerPageMixin {
  List<OrderFeedModel> feedItems = [];
  bool isLoading = true;
  String? error;
  late final OrdersApi _ordersApi;
  late final ApplicationsApi _applicationsApi;

  @override
  void initState() {
    super.initState();
    _ordersApi = sl<OrdersApi>();
    _applicationsApi = sl<ApplicationsApi>();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final feedResponse = await _ordersApi.getOrders(page: 1, size: 20);
      debugPrint('FeedPage: Orders loaded, items=${feedResponse.items.length}');

      final applications = await _applicationsApi.getMyApplications();
      debugPrint('FeedPage: Applications: ${applications.length}');

      final appliedOrderIds = applications
          .where(
            (app) =>
                app.status == ApplicationStatus.pending ||
                app.status == ApplicationStatus.accepted,
          )
          .map((app) => app.orderId)
          .toSet();

      final filteredItems = feedResponse.items
          .where((item) => !appliedOrderIds.contains(item.orderId))
          .where((item) => item.hasAvailableSpecializations)
          .toList();

      if (mounted) {
        setState(() {
          feedItems = filteredItems;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('FeedPage: Error loading feed: $e');
      if (mounted) {
        setState(() {
          error = 'Не удалось загрузить проекты';
          isLoading = false;
        });
      }
    }
  }

  void _handleMoreDetails(OrderFeedModel item) {
    final availableSpecs = item.availableSpecializations;

    if (availableSpecs.length == 1) {
      final spec = availableSpecs.first;
      final queryParams = spec.vacancyId != null
          ? '?vacancy_id=${spec.vacancyId}'
          : '?specialization=${Uri.encodeComponent(spec.specialization)}';

      context.push(
        '${AppRouter.projectDetailsRoute}/${item.orderId}$queryParams',
      );
    } else if (availableSpecs.length > 1) {
      _showVacancySelectionModal(item);
    }
  }

  void _showVacancySelectionModal(OrderFeedModel item) {
    final parentContext = context;
    debugPrint('FeedPage: Showing vacancy modal for order: ${item.orderId}');

    VacancySelectionModal.show(
      context: context,
      orderId: item.orderId,
      onSpecializationSelected: (selectedSpecialization) {
        debugPrint(
          'FeedPage: Vacancy selected: ${selectedSpecialization.vacancyId}',
        );

        Navigator.of(parentContext, rootNavigator: true).pop();

        parentContext.push(
          '${AppRouter.projectDetailsRoute}/${item.orderId}?vacancy_id=${selectedSpecialization.vacancyId}',
        );
        debugPrint(
          'FeedPage: Navigating to ${AppRouter.projectDetailsRoute}/${item.orderId}?vacancy_id=${selectedSpecialization.vacancyId}',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
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
                    : feedItems.isEmpty
                    ? _buildEmptyState()
                    : _buildFeedContent(),
              ),
            ],
          ),
        ),
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
            'Проекты для вас',
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
          ElevatedButton(onPressed: _loadFeed, child: const Text('Повторить')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48.w,
            color: AppColors.primaryText.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'Пока нет доступных проектов',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 18.sp,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent() {
    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 31.h, 20.w, 100.h),
        itemCount: feedItems.length,
        itemBuilder: (context, index) {
          final item = feedItems[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 26.h),
            child: AnimatedCard(
              onTap: () => _handleMoreDetails(item),
              child: OrderFeedCard(
                orderFeed: item,
                onTapMoreDetails: () => _handleMoreDetails(item),
              ),
            ),
          );
        },
      ),
    );
  }
}
