import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../auth/presentation/widgets/gradient_background.dart';
import '../../../data/repositories/orders_repository_impl.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/usecases/get_my_orders.dart';
import '../../widgets/client/onboarding_steps.dart';
import '../../widgets/client/waiting_order_state.dart';
import '../../widgets/client/active_order_state.dart';
import '../../widgets/client/add_order_button.dart';
import '../../widgets/client/callback_requested_state.dart';
import '../../widgets/client/profile_popup_menu.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../../shared/utils/help_utils.dart';
import '../../../../../shared/utils/help_request_utils.dart';
import '../../../../../shared/services/callback_button_manager.dart';
import '../../../../../shared/state/orders_state_manager.dart';

/// My Orders page displaying user's orders or empty state
class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with WidgetsBindingObserver {
  List<Order> orders = [];
  bool isLoading = true;
  late final GetMyOrders _getMyOrdersUseCase;
  late final OrdersStateManager _ordersStateManager;
  late final CallbackButtonManager _callbackButtonManager;
  final GlobalKey _profileIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final apiService = sl<ApiService>();
    final repository = OrdersRepositoryImpl(apiService);
    _getMyOrdersUseCase = GetMyOrders(repository);
    _ordersStateManager = sl<OrdersStateManager>();
    _callbackButtonManager = CallbackButtonManager.getInstance('my_orders');

    // Listen to orders state changes
    _ordersStateManager.addListener(_onOrdersStateChanged);

    // Load orders on page open
    _loadOrders();
  }

  void _onOrdersStateChanged() {
    if (mounted) {
      setState(() {
        orders = _ordersStateManager.orders;
        isLoading = _ordersStateManager.isLoading;
      });

      // Show user-friendly error message for timeouts
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ordersStateManager.removeListener(_onOrdersStateChanged);
    CallbackButtonManager.disposeInstance('my_orders');
    super.dispose();
  }

  Future<void> _requestCallback() async {
    await _callbackButtonManager.requestCallback(
      onSuccess: () {
        if (mounted) {
          // Add callback order to state so my_orders_page updates immediately
          final callbackOrder = Order(
            id: 'callback_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Admin Help Request',
            description: 'Request for callback',
            status: 'pending',
            createdAt: DateTime.now(),
          );
          _ordersStateManager.addOrderOptimistically(callbackOrder);

          context.push('/callback-accepted');
        }
      },
      onError: (error) {
        if (!mounted || !HelpRequestUtils.shouldShowDialog(error)) return;
        HelpRequestUtils.showErrorDialog(context, error);
      },
    );
  }

  Future<List<Order>> _fetchAndSortOrders() async {
    final fetchedOrders = await _getMyOrdersUseCase();

    fetchedOrders.sort((a, b) {
      if (a.status == 'approved' && b.status != 'approved') return -1;
      if (a.status != 'approved' && b.status == 'approved') return 1;

      final aIsCallback = a.title == 'Admin Help Request';
      final bIsCallback = b.title == 'Admin Help Request';

      if (aIsCallback && !bIsCallback) return -1;
      if (!aIsCallback && bIsCallback) return 1;

      return 0;
    });

    return fetchedOrders;
  }

  Future<void> _loadOrders() async {
    await _ordersStateManager.refreshOrders(_fetchAndSortOrders);
  }

  Future<void> _onPullToRefresh() async {
    try {
      final fetchedOrders = await _fetchAndSortOrders();
      _ordersStateManager.setOrders(fetchedOrders);
    } catch (e) {
      _ordersStateManager.setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.blueAccent,
            onRefresh: _onPullToRefresh,
            child: _buildScrollView(),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollView() {
    final slivers = <Widget>[_buildHeaderSliver()];

    if (isLoading) {
      slivers.add(_buildLoadingSliver());
    } else if (orders.isEmpty) {
      slivers.addAll(_buildEmptyStateSlivers());
    } else {
      slivers.addAll(_buildOrdersSlivers());
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );
  }

  Widget _buildHeaderSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getPageTitle(),
                      style: AppTextStyles.pageTitle,
                    ),
                  ),
                  GestureDetector(
                    key: _profileIconKey,
                    onTap: () {
                      showProfilePopupMenu(context, _profileIconKey);
                    },
                    child: Container(
                      width: 29.w,
                      height: 31.h,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/svgs/profile_icon.svg',
                        width: 19.w,
                        height: 20.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 31.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }

  List<Widget> _buildEmptyStateSlivers() {
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        sliver: const SliverToBoxAdapter(child: OnboardingSteps()),
      ),
      _buildEmptyFooterSliver(),
    ];
  }

  Widget _buildEmptyFooterSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 51.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 22.h),
            _buildEmptyFooterContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFooterContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Create order button
          SizedBox(
            width: 354.w,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                context.push('/new-order');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppLocalizations.of(context)!.orders_create_order_button,
                  style: AppTextStyles.buttonText,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 28.h),
          // Callback link
          ListenableBuilder(
            listenable: _callbackButtonManager,
            builder: (context, child) {
              final isPending = _callbackButtonManager.isPending;
              return GestureDetector(
                onTap: isPending ? null : _requestCallback,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending) ...[
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.linkColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        isPending ? 'Отправляем запрос...' : 'Заказать звонок',
                        style: AppTextStyles.linkText.copyWith(
                          color: isPending
                              ? AppColors.secondaryText
                              : AppColors.linkColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrdersSlivers() {
    debugPrint('🎨 [MyOrdersPage] Building ${orders.length} order slivers');
    for (int i = 0; i < orders.length; i++) {
      debugPrint(
        '  - Building order $i: ${orders[i].title}, status: ${orders[i].status}, hasContracts: ${orders[i].hasContracts}',
      );
    }

    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index < orders.length) {
              final order = orders[index];
              debugPrint(
                '🔧 [MyOrdersPage] Rendering order at index $index: ${order.title}',
              );
              return Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: _buildOrderWidget(order),
              );
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 0.h),
              child: _hasActiveOrders()
                  ? const AddProjectButton()
                  : const AddOrderButton(),
            );
          }, childCount: orders.length + 1),
        ),
      ),
      _buildOrdersFooterSliver(),
    ];
  }

  Widget _buildOrdersFooterSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 50.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 22.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    await HelpUtils.showSocialLinksModal(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.orders_help_button,
                    style: AppTextStyles.footerText.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle() {
    if (orders.isEmpty) {
      return AppLocalizations.of(
        context,
      )!.orders_getting_started_title.replaceAll(':', '');
    } else {
      return 'Мои проекты';
    }
  }

  Widget _buildOrderWidget(Order order) {
    // Check order status to determine state
    if (order.status == 'approved') {
      // Active order state
      return ActiveOrderState(order: order);
    } else if (order.title == 'Admin Help Request') {
      // Callback order state - shown in list but with different UI (no interaction)
      return const CallbackRequestedState();
    } else {
      // Waiting for manager response state (pending or other statuses)
      return WaitingOrderState(order: order);
    }
  }

  bool _hasActiveOrders() {
    return orders.any((order) => order.status == 'approved');
  }
}
