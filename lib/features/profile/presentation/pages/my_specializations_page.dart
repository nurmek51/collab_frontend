import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/services/freelancer_onboarding_service.dart';
import '../../../../shared/api/freelancer_api.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../auth/presentation/widgets/gradient_background.dart';

/// My Specializations page for managing freelancer specializations
class MySpecializationsPage extends StatefulWidget {
  final List<SpecializationWithLevel> specializationsWithLevels;

  const MySpecializationsPage({
    super.key,
    required this.specializationsWithLevels,
  });

  @override
  State<MySpecializationsPage> createState() => _MySpecializationsPageState();
}

class _MySpecializationsPageState extends State<MySpecializationsPage> {
  late List<SpecializationWithLevel> _specializations;
  late FreelancerOnboardingService _onboardingService;
  late FreelancerApi _freelancerApi;

  @override
  void initState() {
    super.initState();
    _specializations = List.from(widget.specializationsWithLevels);
    _onboardingService = sl<FreelancerOnboardingService>();
    _freelancerApi = sl<FreelancerApi>();

    // Always refresh data when page initializes to ensure fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkForUpdatedSpecializations();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkForUpdatedSpecializations() async {
    try {
      // Get fresh data from API
      final profileResponse = await _freelancerApi.getProfile();
      final updatedSpecs =
          (profileResponse['specializations_with_levels'] as List<dynamic>?)
              ?.map(
                (spec) => SpecializationWithLevel.fromJson(
                  spec as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [];

      // Always update the state with fresh data
      if (mounted) {
        setState(() {
          _specializations = updatedSpecs;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing from API: $e');
      // Fallback to onboarding service
      try {
        final currentState = await _onboardingService.getCurrentState();
        if (mounted) {
          setState(() {
            _specializations = List.from(
              currentState.specializationsWithLevels,
            );
          });
        }
      } catch (e2) {
        debugPrint('Error refreshing from onboarding service: $e2');
      }
    }
  }

  void _navigateToSpecializationDetails(SpecializationWithLevel spec) async {
    // Navigate to specialization details page
    await context.push(
      '/specialization-details',
      extra: {
        'specialization': spec.specialization,
        'skillLevel': spec.skillLevel ?? 'junior',
        'isNew': false,
      },
    );

    // Note: After deletion, user is redirected to freelancer-profile page automatically
    // No refresh needed here since deletion navigates away from this page
  }

  Future<void> _navigateToAddSpecialization() async {
    // Pre-populate the onboarding service with current specializations
    await _onboardingService.updateState(
      FreelancerOnboardingState(specializationsWithLevels: _specializations),
    );

    // Store context before async operations
    if (!mounted) return;

    // Navigate to specializations page with edit mode
    await context.push(
      '/specializations',
      extra: {
        'isEditMode': true,
        'isFromMySpecializations': true,
        'currentSpecializations': _specializations,
      },
    );

    // Always refresh after returning from add flow
    if (mounted) {
      await _checkForUpdatedSpecializations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header with back button
              _buildHeader(),

              // Main content
              Expanded(
                child: _specializations.isEmpty
                    ? _buildEmptyState()
                    : _buildSpecializationsList(),
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
        children: [
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: SvgPicture.asset(
              'assets/svgs/back_arrow.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryText,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Мои специализации',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w700,
              fontSize: 26.sp,
              height: 1.149,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svgs/specialization_icon.svg',
            width: 64.w,
            height: 64.h,
            colorFilter: ColorFilter.mode(
              AppColors.primaryText.withValues(alpha: 0.3),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Специализации не добавлены',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              height: 1.3,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Добавьте свои специализации\nчтобы начать получать заказы',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              height: 1.3,
              color: AppColors.primaryText.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          _buildAddSpecializationButton(),
        ],
      ),
    );
  }

  Widget _buildSpecializationsList() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        children: [
          // List of specializations
          ..._specializations.asMap().entries.map((entry) {
            final index = entry.key;
            final spec = entry.value;
            final isLast = index == _specializations.length - 1;

            return Column(
              children: [
                _buildSpecializationCard(spec),
                if (!isLast) SizedBox(height: 16.h),
              ],
            );
          }),

          // Add new specialization button
          SizedBox(height: 24.h),
          _buildAddSpecializationButton(),

          // Bottom spacing
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildSpecializationCard(SpecializationWithLevel spec) {
    return GestureDetector(
      onTap: () => _navigateToSpecializationDetails(spec),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side with specialization name only
            Expanded(
              child: Text(
                SpecializationConstants.getDisplayNameFromKey(
                  spec.specialization,
                ),
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                  height: 1.3,
                  color: AppColors.primaryText,
                ),
              ),
            ),

            // Arrow icon
            SvgPicture.asset(
              'assets/svgs/mini-arrow_icon.svg',
              width: 9.28.w,
              height: 16.84.h,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryText,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSpecializationButton() {
    return GestureDetector(
      onTap: _navigateToAddSpecialization,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svgs/add_icon.svg',
              width: 20.w,
              height: 20.h,
              colorFilter: const ColorFilter.mode(
                AppColors.blueAccent,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Добавить роль',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
                height: 1.3,
                color: AppColors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
