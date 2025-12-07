import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/animated_buttons.dart';
import '../../../../../shared/widgets/full_width_separator.dart';
import '../../../../../shared/api/orders_api.dart';
import '../../../../../shared/api/companies_api.dart';
import '../../../../../shared/api/freelancer_api.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../../shared/utils/deep_link_utils.dart';
import '../../../../auth/presentation/widgets/gradient_background.dart';
import '../../../data/models/order_details_model.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/freelancer_model.dart';
import '../../widgets/colleague_info_modal_new.dart';
import '../../../../../shared/widgets/social_links_modal.dart';

/// Client Order Details Page
/// Shows order details from client perspective with team members and payment history
class ClientOrderDetailsPage extends StatefulWidget {
  final String orderId;

  const ClientOrderDetailsPage({super.key, required this.orderId});

  @override
  State<ClientOrderDetailsPage> createState() => _ClientOrderDetailsPageState();
}

class _ClientOrderDetailsPageState extends State<ClientOrderDetailsPage> {
  late final OrdersApi _ordersApi;
  late final CompaniesApi _companiesApi;
  late final FreelancerApi _freelancerApi;
  OrderDetailsModel? orderDetails;
  CompanyModel? companyDetails;
  bool isLoading = true;
  String? error;
  bool _isDescriptionExpanded = false;
  List<FreelancerModel> colleagues = [];
  bool isLoadingColleagues = false;

  @override
  void initState() {
    super.initState();
    _ordersApi = sl<OrdersApi>();
    _companiesApi = sl<CompaniesApi>();
    _freelancerApi = sl<FreelancerApi>();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await _ordersApi.getOrderById(widget.orderId);
      final order = OrderDetailsModel.fromJson(response);

      // Load company details
      CompanyModel? company;
      try {
        final companyResponse = await _companiesApi.getCompanyById(
          order.companyId,
        );
        if (companyResponse != null) {
          company = CompanyModel.fromJson(companyResponse);
        }
      } catch (e) {
        debugPrint('Company details not available: $e');
      }

      setState(() {
        orderDetails = order;
        companyDetails = company;
        isLoading = false;
      });

      // Load colleagues after order details are loaded
      _loadColleagues();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadColleagues() async {
    if (orderDetails?.orderColleagues == null ||
        orderDetails!.orderColleagues!.isEmpty) {
      return;
    }

    setState(() {
      isLoadingColleagues = true;
    });

    try {
      final List<FreelancerModel> fetchedColleagues = [];

      for (final colleagueId in orderDetails!.orderColleagues!) {
        try {
          final response = await _freelancerApi.getFreelancerById(colleagueId);
          final colleague = FreelancerModel.fromJson(response);
          fetchedColleagues.add(colleague);
        } catch (e) {
          debugPrint('Failed to load colleague $colleagueId: $e');
        }
      }

      setState(() {
        colleagues = fetchedColleagues;
        isLoadingColleagues = false;
      });
    } catch (e) {
      debugPrint('Failed to load colleagues: $e');
      setState(() {
        isLoadingColleagues = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? _buildErrorState()
              : _buildContent(),
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
          Text(
            error!,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: const Color(0xFF96A4B3),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadOrderDetails,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (orderDetails == null) return const SizedBox();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            SizedBox(height: 20.h),

            // Main content sections
            _buildTaskSection(),
            SizedBox(height: 2.h),
            const FullWidthSeparator(),
            SizedBox(height: 2.h),
            _buildTeamSection(),
            SizedBox(height: 2.h),
            const FullWidthSeparator(),
            SizedBox(height: 2.h),
            // TODO: Uncomment payment history section when payments data is available
            // _buildPaymentHistorySection(),
            // SizedBox(height: 2.h),
            // const FullWidthSeparator(),
            // SizedBox(height: 2.h),

            // Bottom actions
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              size: 32.w,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '${companyDetails?.companyName ?? 'Компания'}: данные проекта',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w800,
              fontSize: 24.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Задача',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 6.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderDetails?.orderDescription ?? 'Описание задачи не указано',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  height: 1.3,
                  color: AppColors.primaryText,
                ),
                maxLines: _isDescriptionExpanded ? null : 8,
                overflow: _isDescriptionExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
              if (_isDescriptionExpanded ||
                  _needsExpansion(orderDetails?.orderDescription ?? ''))
                SizedBox(height: 10.h),
              if (_isDescriptionExpanded ||
                  _needsExpansion(orderDetails?.orderDescription ?? ''))
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDescriptionExpanded = !_isDescriptionExpanded;
                    });
                  },
                  child: Text(
                    _isDescriptionExpanded ? 'Свернуть' : 'Подробнее',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      height: 1.3,
                      color: const Color(0xFF2782E3),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'На проекте работают',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 10.h),
          if (isLoadingColleagues)
            const Center(child: CircularProgressIndicator())
          else if (colleagues.isEmpty)
            Text(
              'Информация о команде недоступна',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                height: 1.3,
                color: const Color(0xFF96A4B3),
              ),
            )
          else
            Column(
              children: [
                ...colleagues.asMap().entries.map((entry) {
                  final index = entry.key;
                  final colleague = entry.value;
                  return Column(
                    children: [
                      if (index > 0) SizedBox(height: 8.h),
                      _buildTeamMember(colleague),
                    ],
                  );
                }),
                SizedBox(height: 16.h),
                _buildMonthlyCost(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(FreelancerModel colleague) {
    return GestureDetector(
      onTap: () => _showColleagueInfo(colleague),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0x0D000000)),
        ),
        child: Row(
          children: [
            Container(
              width: 51.w,
              height: 51.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD9D9D9),
              ),
              child: colleague.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        colleague.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 25.w,
                          color: AppColors.primaryText,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 25.w,
                      color: AppColors.primaryText,
                    ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    colleague.fullName,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      height: 1.3,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    colleague.specializationWithLevel,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      height: 1.3,
                      color: const Color(0xFF96A4B3),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getColleagueSalary(colleague),
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      height: 1.3,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCost() {
    double totalMonthlySalary = _calculateTotalMonthlySalary();
    String formattedAmount = _formatCurrency(totalMonthlySalary);

    return Container(
      padding: EdgeInsets.only(top: 16.h),
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
            formattedAmount,
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

  String _getColleagueSalary(FreelancerModel colleague) {
    // Find matching specialization in order
    for (final spec in orderDetails?.orderSpecializations ?? []) {
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

    // Default fallback
    return '10 000 ₸/час';
  }

  double _calculateTotalMonthlySalary() {
    double total = 0.0;

    for (final colleague in colleagues) {
      // Find matching specialization in order
      for (final spec in orderDetails?.orderSpecializations ?? []) {
        if (spec.specialization ==
            colleague.specializationsWithLevels.first.specialization) {
          double salary = spec.conditions.salary;
          String payPer = spec.conditions.payPer;

          // Convert to monthly amount
          if (payPer == 'hour') {
            // Assuming 160 hours per month (20 working days * 8 hours)
            total += salary * 160;
          } else if (payPer == 'month') {
            total += salary;
          } else if (payPer == 'project') {
            // For project-based, assume it's monthly equivalent
            total += salary;
          }
          break;
        }
      }
    }

    return total;
  }

  String _formatCurrency(double amount) {
    // Format number with spaces as thousands separator
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

  Widget _buildDocumentItem(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0x0D000000)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                height: 1.3,
                color: AppColors.primaryText,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.w,
            color: const Color(0xFFA9B6B9),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistorySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'История платежей',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'История платежей недоступна',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              height: 1.3,
              color: const Color(0xFF96A4B3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Container(
            width: 354.w,
            child: AnimatedPrimaryButton(
              onPressed: () async {
                // Open chat link via deep linking
                final chatLink = orderDetails?.chatLink;
                if (chatLink != null && chatLink.isNotEmpty) {
                  final success = await DeepLinkUtils.openDeepLink(chatLink);
                  if (!success) {
                    if (mounted) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text(
                      //       'Не удалось открыть чат. Попробуйте позже.',
                      //     ),
                      //     backgroundColor: Colors.orange,
                      //   ),
                      // );
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ссылка на чат недоступна.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              },
              text: 'Рабочий чат',
            ),
          ),
          SizedBox(height: 26.h),
          GestureDetector(
            onTap: () => _openContactModal(),
            child: Text(
              'Поддержка Collab',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                height: 1.3,
                color: const Color(0xFF2782E3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColleagueInfo(FreelancerModel colleague) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ColleagueInfoModal(
        colleague: colleague,
        orderDetails: orderDetails,
        onMessageTap: () {
          Navigator.pop(context);
          // TODO: Implement messaging functionality
        },
      ),
    );
  }

  void _openContactModal() {
    SocialLinksModal.show(context);
  }

  bool _needsExpansion(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          height: 1.3,
          color: AppColors.primaryText,
        ),
      ),
      maxLines: 8,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 354.w);
    return textPainter.didExceedMaxLines;
  }
}
