import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/order_condition_constants.dart';
import '../../../../../core/widgets/animated_buttons.dart';
import '../../../../../shared/widgets/full_width_separator.dart';
import '../../../../../shared/api/orders_api.dart';
import '../../../../../shared/api/applications_api.dart';
import '../../../../../shared/api/companies_api.dart';
import '../../../../../shared/api/freelancer_api.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../../shared/utils/deep_link_utils.dart';
import '../../../data/models/order_details_model.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/specialization_offer_model.dart';
import '../../../data/models/freelancer_model.dart';
import '../../../data/models/vacancy_application_models.dart';
// TODO: Import will be restored when modal is implemented
// import '../../widgets/freelancer/just_a_minute_modal.dart';
import '../../widgets/colleague_info_modal_new.dart';
import '../../../../../core/navigation/app_router.dart';

import '../../../../../core/constants/specialization_constants.dart';

/// Project Details Page (Freelancer View)
/// Shows full project details including client, tasks, team members, etc.
class ProjectDetailsPage extends StatefulWidget {
  final String orderId;
  final String? selectedSpecialization;
  final String? vacancyId;
  final bool fromMyWork;

  const ProjectDetailsPage({
    super.key,
    required this.orderId,
    this.selectedSpecialization,
    this.vacancyId,
    this.fromMyWork = false,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late final OrdersApi _ordersApi;
  late final ApplicationsApi _applicationsApi;
  late final CompaniesApi _companiesApi;
  late final FreelancerApi _freelancerApi;
  OrderDetailsModel? orderDetails;
  CompanyModel? companyDetails;
  SpecializationOfferModel? selectedSpecializationOffer;
  String? freelancerId;
  bool isLoading = true;
  String? error;
  bool _isDescriptionExpanded = false;
  bool isAcceptedFreelancer = false;
  List<FreelancerModel> colleagues = [];
  bool isLoadingColleagues = false;

  @override
  void initState() {
    super.initState();
    _ordersApi = sl<OrdersApi>();
    _applicationsApi = sl<ApplicationsApi>();
    _companiesApi = sl<CompaniesApi>();
    _freelancerApi = sl<FreelancerApi>();
    _loadOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? _buildErrorState()
            : _buildContent(),
      ),
    );
  }

  @override
  void didUpdateWidget(ProjectDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the selected specialization changed, update the selected specialization offer
    if (oldWidget.selectedSpecialization != widget.selectedSpecialization) {
      debugPrint(
        'ProjectDetailsPage: selectedSpecialization changed from ${oldWidget.selectedSpecialization} to ${widget.selectedSpecialization}',
      );
      if (orderDetails != null &&
          orderDetails!.orderSpecializations.isNotEmpty) {
        final newSelectedOffer = widget.selectedSpecialization != null
            ? orderDetails!.orderSpecializations.firstWhere(
                (offer) =>
                    offer.specialization == widget.selectedSpecialization,
                orElse: () => orderDetails!.orderSpecializations.first,
              )
            : orderDetails!.orderSpecializations.first;

        debugPrint(
          'ProjectDetailsPage: updating selectedSpecializationOffer to ${newSelectedOffer.specialization}',
        );
        setState(() {
          selectedSpecializationOffer = newSelectedOffer;
        });
      }
    }
  }

  Future<void> _loadOrderDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load order details
      final response = await _ordersApi.getOrderById(widget.orderId);
      final details = OrderDetailsModel.fromJson(response);

      // Load company details if available
      CompanyModel? company;
      if (details.companyId.isNotEmpty) {
        try {
          final companyResponse = await _companiesApi.getCompanyById(
            details.companyId,
          );
          if (companyResponse != null) {
            company = CompanyModel.fromJson(companyResponse);
          }
        } catch (e) {
          debugPrint('Company details not available: $e');
        }
      }

      // Load freelancer profile to get freelancer_id
      String? freelancerIdResult;
      try {
        final freelancerResponse = await _freelancerApi.getProfile();
        freelancerIdResult = freelancerResponse['freelancer_id']?.toString();
      } catch (e) {
        debugPrint('Failed to load freelancer profile: $e');
      }

      // Check if the freelancer was accepted to this order
      bool isAccepted = false;
      if (widget.fromMyWork && freelancerIdResult != null) {
        try {
          final applications = await _applicationsApi.getMyApplications();

          // Find current application safely without relying on extension methods
          ApplicationModel? currentApplication;
          for (var app in applications) {
            if (app.orderId == widget.orderId &&
                app.freelancerId == freelancerIdResult) {
              currentApplication = app;
              break;
            }
          }

          if (currentApplication != null) {
            isAccepted =
                currentApplication.status == ApplicationStatus.accepted;
            // debugPrint('Found application with status: ${currentApplication.status}');
          } else {
            // debugPrint('No application found for order ${widget.orderId} and freelancer $freelancerIdResult');
          }
        } catch (e) {
          // debugPrint('Failed to check application status: $e');
        }
      }

      if (mounted) {
        setState(() {
          orderDetails = details;
          companyDetails = company;
          freelancerId = freelancerIdResult;
          isAcceptedFreelancer = isAccepted;

          // Find the selected specialization offer
          if (details.orderSpecializations.isNotEmpty) {
            // Priority 1: Use vacancyId if provided (new system)
            if (widget.vacancyId != null) {
              selectedSpecializationOffer = details.orderSpecializations
                  .firstWhere(
                    (offer) => offer.vacancyId == widget.vacancyId,
                    orElse: () => details.orderSpecializations.first,
                  );
              debugPrint(
                'ProjectDetailsPage: Using vacancyId=${widget.vacancyId}, found offer=${selectedSpecializationOffer?.specialization}',
              );
            }
            // Priority 2: Fallback to specialization name (legacy system)
            else if (widget.selectedSpecialization != null) {
              selectedSpecializationOffer = details.orderSpecializations
                  .firstWhere(
                    (offer) =>
                        offer.specialization == widget.selectedSpecialization,
                    orElse: () => details.orderSpecializations.first,
                  );
              debugPrint(
                'ProjectDetailsPage: Using selectedSpecialization=${widget.selectedSpecialization}, found offer=${selectedSpecializationOffer?.specialization}',
              );
            }
            // Priority 3: Default to first specialization
            else {
              selectedSpecializationOffer = details.orderSpecializations.first;
              debugPrint(
                'ProjectDetailsPage: No specific selection, using first offer=${selectedSpecializationOffer?.specialization}',
              );
            }
          }

          isLoading = false;
        });

        // Load colleagues after order details are loaded
        _loadColleagues();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load colleagues whenever the dependencies change (e.g., after navigating back)
    _loadColleagues();
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
            onPressed: _loadOrderDetails,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (orderDetails == null) return const SizedBox();

    // Show accepted freelancer state if coming from my work and was accepted
    if (widget.fromMyWork && isAcceptedFreelancer) {
      return _buildAcceptedFreelancerContent();
    }

    // Show regular project details content
    return _buildRegularContent();
  }

  Widget _buildRegularContent() {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(),

              SizedBox(height: 20.h),

              // Main content sections
              _buildTaskSection(),
              SizedBox(height: 2.h),
              const FullWidthSeparator(),
              SizedBox(height: 2.h),
              _buildClientSection(),
              SizedBox(height: 2.h),
              const FullWidthSeparator(),
              SizedBox(height: 2.h),
              _buildConditionsSection(),
              SizedBox(height: 2.h),
              const FullWidthSeparator(),
              SizedBox(height: 2.h),
              _buildRequirementsSection(),

              // Only show separator and bottom actions if NOT fromMyWork
              if (!widget.fromMyWork) ...[
                SizedBox(height: 2.h),
                const FullWidthSeparator(),
                SizedBox(height: 2.h),
                // Bottom actions
                _buildBottomActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptedFreelancerContent() {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Use regular header
              _buildHeader(),
              SizedBox(height: 20.h),
              // Use regular task section
              _buildTaskSection(),
              SizedBox(height: 2.h),
              const FullWidthSeparator(),
              // Use regular client section
              _buildClientSection(),
              SizedBox(height: 2.h),
              const FullWidthSeparator(),

              // TODO: Hide documents section when empty - Condition: if (!documents || Object.keys(documents).length === 0)
              // Accepted documents section (updated to match regular section width/height)
              // _buildAcceptedDocumentsSection(),
              // SizedBox(height: 2.h),
              // const FullWidthSeparator(),

              // Accepted salary section (updated to match regular section width/height)
              _buildAcceptedSalarySection(),
              SizedBox(height: 2.h),
              const FullWidthSeparator(),
              // Accepted team section (updated to match regular section width/height)
              _buildAcceptedTeamSection(),
              SizedBox(height: 2.h),
              const FullWidthSeparator(),
              _buildAcceptedBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
          Container(
            width: double.infinity,
            child: Text(
              selectedSpecializationOffer != null
                  ? SpecializationConstants.getDisplayNameFromKey(
                      selectedSpecializationOffer!.specialization,
                    )
                  : orderDetails?.orderTitle ?? 'Проект',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w700,
                fontSize: 26.sp,
                height: 1.149,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection() {
    return Container(
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
                      color: AppColors.blueAccent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Заказчик',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Company logo/avatar
                    Container(
                      width: 40.98.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: companyDetails?.companyLogo != null
                            ? Image.network(
                                companyDetails!.companyLogo!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildDefaultClientLogo(),
                              )
                            : _buildDefaultClientLogo(),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      companyDetails?.companyName ?? 'Компания',
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
                // TODO: Company UI - Remove clickable behavior, make it look like plain label
                // SvgPicture.asset('assets/svgs/arrow_icon.svg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultClientLogo() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrayBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(Icons.business, size: 20.w, color: AppColors.primaryText),
    );
  }

  Widget _buildConditionsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Условия',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bullet points
              Column(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: index < 4 ? 13.h : 0),
                    child: SvgPicture.asset(
                      'assets/svgs/arrow_icon.svg',
                      width: 12.w,
                      height: 12.w,
                      color: const Color(0xFF96A4B3),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index < 4 ? 4.h : 0),
                      child: Text(
                        _buildConditionsText()[index],
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          height: 1.3,
                          color: AppColors.primaryText,
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
    );
  }

  Widget _buildRequirementsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Требования',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
              height: 1.149,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 10.h),
          // Fixed: Arrow vertical-centering using proper flex alignment
          Column(
            children: _buildRequirementsText()
                .map(
                  (req) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Arrow centered vertically with the text
                        SvgPicture.asset(
                          'assets/svgs/arrow_icon.svg',
                          width: 12.w,
                          height: 12.w,
                          color: const Color(0xFF96A4B3),
                        ),
                        SizedBox(width: 8.w),
                        // Content
                        Expanded(
                          child: Text(
                            req,
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              height: 1.3,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<String> _buildRequirementsText() {
    final raw = (selectedSpecializationOffer?.requirements ?? '').trim();
    if (raw.isEmpty) return ['Требования не указаны'];

    // Split by newlines, bullets, semicolons
    var parts = raw.split(RegExp(r'[\r\n]+|[•;]'));
    parts = parts.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    if (parts.isEmpty) return ['Требования не указаны'];

    // If a single very long paragraph, try to split into sentences
    if (parts.length == 1 && parts.first.length > 200) {
      final sentences = parts.first
          .split(RegExp(r'[\.\?!]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (sentences.length > 1) {
        parts = sentences;
      } else {
        // Fallback: chunk into ~120-char pieces to improve layout
        final text = parts.first;
        final chunks = <String>[];
        for (var i = 0; i < text.length; i += 120) {
          final end = (i + 120) < text.length ? i + 120 : text.length;
          chunks.add(text.substring(i, end).trim());
        }
        parts = chunks.where((s) => s.isNotEmpty).toList();
      }
    }

    return parts;
  }

  List<String> _buildConditionsText() {
    if (selectedSpecializationOffer?.conditions == null) {
      return ['Условия не указаны'];
    }

    final condition = selectedSpecializationOffer!.conditions;
    final conditions = <String>[];

    conditions.add(
      'Оклад: ${condition.salary.toInt()} ₸ / ${OrderConditionConstants.getPayPerDisplay(condition.payPer)}',
    );
    conditions.add(
      'Выплаты: раз в ${OrderConditionConstants.getPayPerDisplay(condition.payPer)}',
    );
    conditions.add('Опыт работы: ${condition.requiredExperience}+ лет');
    conditions.add(
      OrderConditionConstants.getScheduleTypeDisplay(condition.scheduleType),
    );
    conditions.add(
      'Формат работы: ${OrderConditionConstants.getFormatTypeDisplay(condition.formatType)}',
    );

    return conditions;
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Main action button - only show if not from my work
          if (!widget.fromMyWork)
            SizedBox(
              width: double.infinity,
              child: AnimatedPrimaryButton(
                text: 'Откликнуться',
                onPressed: () => _handleRespond(),
              ),
            ),

          if (!widget.fromMyWork) SizedBox(height: 26.h),

          // TODO: Hide secondary actions until implementation
          // Secondary actions
          // Column(
          //   children: [
          //     // TODO: Hide «Share vacancy» button - Conditional render: if (canShare) show where canShare false in spec
          //     GestureDetector(
          //       onTap: () {
          //         // TODO: Implement share functionality
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text('Функция публикации в разработке'),
          //           ),
          //         );
          //       },
          //       child: Text(
          //         'Поделиться вакансией',
          //         style: TextStyle(
          //           fontFamily: 'Ubuntu',
          //           fontWeight: FontWeight.w400,
          //           fontSize: 16.sp,
          //           height: 1.3,
          //           color: AppColors.blueAccent,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),

          //     SizedBox(height: 26.h),

          //     // TODO: Hide «Уточнить детали» button - Remove or hide
          //     GestureDetector(
          //       onTap: () {
          //         // TODO: Implement clarify details functionality
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text('Функция уточнения деталей в разработке'),
          //           ),
          //         );
          //       },
          //       child: Text(
          //         'Уточнить детали',
          //         style: TextStyle(
          //           fontFamily: 'Ubuntu',
          //           fontWeight: FontWeight.w400,
          //           fontSize: 16.sp,
          //           height: 1.3,
          //           color: AppColors.blueAccent,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Future<void> _handleRespond() async {
    // TODO: Hide the «just_a_minute_modal» on apply - Apply button should call applyToProject() and show direct success/failure UI
    // _showJustAMinuteModal();

    // Direct apply functionality (commented modal flow)
    _proceedWithResponse();
  }

  // TODO: Comment out modal functionality - to be implemented later
  // void _showJustAMinuteModal() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => JustAMinuteModal(
  //       onSignDocuments: () {
  //         Navigator.of(context).pop();
  //         _proceedWithResponse();
  //       },
  //       onClarifyDetails: () {
  //         Navigator.of(context).pop();
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Функция уточнения деталей в разработке'),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Future<void> _proceedWithResponse() async {
    if (orderDetails == null) return;

    // Check if we have freelancer_id
    if (freelancerId == null || freelancerId!.isEmpty) {
      _showErrorSnackBar('Не удалось получить ID профиля фрилансера');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Prepare application request
      final String? vacancyId = selectedSpecializationOffer?.vacancyId;

      // Check eligibility first (optional but recommended)
      try {
        final eligibility = await _applicationsApi.checkEligibility(
          orderDetails!.orderId,
          vacancyId: vacancyId,
        );

        if (!eligibility.eligible) {
          if (mounted) {
            _showErrorSnackBar(
              'Не удается подать заявку: ${eligibility.reason}',
            );
          }
          return;
        }
      } catch (e) {
        // Eligibility check failed, but we can still proceed
        debugPrint('Eligibility check failed: $e');
      }

      // Create application request
      final applicationRequest = OrderApplicationCreate(
        orderId: orderDetails!.orderId,
        vacancyId: vacancyId,
        freelancerId: freelancerId,
      );

      // Apply to the order
      await _applicationsApi.createApplication(applicationRequest);

      if (mounted) {
        // Navigate to callback success page
        context.go(AppRouter.callbackSuccessRoute);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Произошла ошибка: ${e.toString()}';

        // Handle specific error cases from the API documentation
        if (e.toString().contains('409') || e.toString().contains('Conflict')) {
          errorMessage =
              'Эта вакансия была только что занята — пожалуйста, выберите другую специализацию.';
          // Optionally refresh available specializations here
        } else if (e.toString().contains('404') ||
            e.toString().contains('NotFound')) {
          errorMessage =
              'Заказ или профиль не найден. Пожалуйста, попробуйте еще раз или обратитесь в службу поддержки.';
        } else if (e.toString().contains('400') ||
            e.toString().contains('BadRequest')) {
          errorMessage =
              'Недопустимый запрос. Пожалуйста, обновите страницу и попробуйте еще раз.';
        }

        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
    textPainter.layout(maxWidth: 1.sw - 40.w);
    return textPainter.didExceedMaxLines;
  }

  // ========== ACCEPTED FREELANCER STATE METHODS ==========

  // TODO: Hide documents section when empty - Will be implemented later
  // Widget _buildAcceptedDocumentsSection() {
  //   return Container(
  //     width: 354.w,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Документы',
  //           style: TextStyle(
  //             fontFamily: 'Ubuntu',
  //             fontWeight: FontWeight.w500,
  //             fontSize: 16.sp,
  //             height: 1.3,
  //             color: AppColors.primaryText,
  //           ),
  //         ),
  //         SizedBox(height: 12.h),
  //         _buildDocumentItem('Договор об оказании услуг'),
  //         SizedBox(height: 12.h),
  //         _buildDocumentItem('Ежемесячные документы'),
  //       ],
  //     ),
  //   );
  // }

  // TODO: Document item method - Will be restored when documents section is implemented
  // Widget _buildDocumentItem(String title) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
  //     decoration: BoxDecoration(
  //       color: AppColors.white,
  //       borderRadius: BorderRadius.circular(16.r),
  //       border: Border.all(color: const Color(0x0D000000)),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Expanded(
  //           child: Text(
  //             title,
  //             style: TextStyle(
  //               fontFamily: 'Ubuntu',
  //               fontWeight: FontWeight.w400,
  //               fontSize: 16.sp,
  //               height: 1.3,
  //               color: AppColors.primaryText,
  //             ),
  //           ),
  //         ),
  //         SvgPicture.asset('assets/svgs/arrow_icon.svg'),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAcceptedSalarySection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваш оклад',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 16.w,
                color: AppColors.primaryText,
              ),
              SizedBox(width: 8.w),
              Text(
                selectedSpecializationOffer?.conditions != null
                    ? '${selectedSpecializationOffer!.conditions.salary.toInt()} ₸ / ${OrderConditionConstants.getPayPerDisplay(selectedSpecializationOffer!.conditions.payPer)}'
                    : '999 999 ₸ / месяц',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  height: 1.3,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedTeamSection() {
    return Container(
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
              children: colleagues.asMap().entries.map((entry) {
                final index = entry.key;
                final colleague = entry.value;
                return Column(
                  children: [
                    if (index > 0) SizedBox(height: 8.h),
                    _buildTeamMemberFromData(colleague),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberFromData(FreelancerModel colleague) {
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD9D9D9),
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
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildAcceptedBottomActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: AnimatedPrimaryButton(
              onPressed: () async {
                // Deep link implementation similar to client order details page
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
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //     content: Text('Ссылка на чат недоступна.'),
                    //     backgroundColor: Colors.orange,
                    //   ),
                    // );
                  }
                }
              },
              text: 'Рабочий чат',
            ),
          ),
          SizedBox(height: 26.h),

          // TODO: Hide «Поддержка collab» - Remove button on this page
          // Text(
          //   'Поддержка Collab',
          //   style: TextStyle(
          //     fontFamily: 'Ubuntu',
          //     fontWeight: FontWeight.w400,
          //     fontSize: 16.sp,
          //     height: 1.3,
          //     color: const Color(0xFF2782E3),
          //   ),
          // ),
        ],
      ),
    );
  }
}
