import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/presentation/widgets/gradient_background.dart';
import '../../domain/entities/freelancer_profile.dart';
import '../../../../shared/api/freelancer_api.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/widgets/freelancer_flow_exports.dart';
import '../../../auth/presentation/widgets/exit_confirm_modal.dart';
import '../../../auth/presentation/widgets/delete_account_confirm_modal.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../../../../shared/services/freelancer_profile_status_manager.dart';
import '../widgets/freelancer_resume_section.dart';
import '../../../../shared/widgets/editable_profile_avatar.dart';

/// Freelancer Profile page for viewing freelancer profile information
class FreelancerProfilePage extends StatefulWidget {
  const FreelancerProfilePage({super.key});

  @override
  State<FreelancerProfilePage> createState() => _FreelancerProfilePageState();
}

class _FreelancerProfilePageState extends State<FreelancerProfilePage>
    with FreelancerPageMixin {
  bool _isLoading = true;
  FreelancerProfile? _profile;
  String? _errorMessage;
  bool _isLoggingOut = false;

  late final FreelancerApi _freelancerApi;
  late final Logout _logoutUseCase;

  @override
  void initState() {
    super.initState();
    _freelancerApi = sl<FreelancerApi>();
    _logoutUseCase = sl<Logout>();
    _loadProfile();
  }

  Future<void> _handleLogout() async {
    // Show exit confirmation modal
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ExitConfirmModal(),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Perform logout
      await _logoutUseCase.call();

      // Navigate to welcome page
      if (mounted) {
        context.go('/welcome');
      }
    } catch (e) {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Refresh profile status cache with fresh data when opening profile page
      final statusManager = sl<FreelancerProfileStatusManager>();
      await statusManager.refreshProfile();

      final response = await _freelancerApi.getProfile();
      final profileData = response;

      // Convert the API response to FreelancerProfile entity
      final profile = FreelancerProfile(
        id: profileData['freelancer_id']?.toString() ?? '',
        userId: profileData['user_id']?.toString() ?? '',
        name: profileData['name']?.toString() ?? '',
        surname: profileData['surname']?.toString() ?? '',
        iin: profileData['iin']?.toString() ?? '',
        city: profileData['city']?.toString() ?? '',
        specializationsWithLevels:
            (profileData['specializations_with_levels'] as List<dynamic>?)
                ?.map((spec) {
                  if (spec is Map<String, dynamic>) {
                    return SpecializationWithLevel(
                      specialization: spec['specialization']?.toString() ?? '',
                      skillLevel: spec['skill_level']?.toString(),
                    );
                  }
                  return null;
                })
                .where((spec) => spec != null)
                .cast<SpecializationWithLevel>()
                .toList() ??
            [],
        status: profileData['status']?.toString() ?? 'incomplete',
        createdAt: profileData['created_at'] != null
            ? DateTime.tryParse(profileData['created_at'].toString()) ??
                  DateTime.now()
            : DateTime.now(),
        updatedAt: profileData['updated_at'] != null
            ? DateTime.tryParse(profileData['updated_at'].toString()) ??
                  DateTime.now()
            : DateTime.now(),
        email: profileData['email']?.toString(),
        portfolioLinks:
            (profileData['portfolio_links'] as Map<String, dynamic>?)
                ?.cast<String, String>(),
        socialLinks: (profileData['social_links'] as Map<String, dynamic>?)
            ?.cast<String, String>(),
        hasResume: profileData['has_resume'] as bool? ?? false,
        resumeFilename: profileData['resume_filename'] as String?,
        resumeUploadedAt: profileData['resume_uploaded_at'] != null
            ? DateTime.tryParse(profileData['resume_uploaded_at'].toString())
            : null,
        hasAvatar: profileData['has_avatar'] as bool? ?? false,
        avatarUploadedAt: profileData['avatar_uploaded_at'] != null
            ? DateTime.tryParse(profileData['avatar_uploaded_at'].toString())
            : null,
      );

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
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
              // Header with title
              _buildHeader(),

              // Main content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? _buildErrorView()
                    : _profile != null
                    ? _buildProfileContent()
                    : _buildEmptyView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.w,
            color: AppColors.primaryText.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            _errorMessage!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              'Попробовать снова',
              style: AppTextStyles.buttonText.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64.w,
            color: AppColors.primaryText.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'Профиль не найден',
            style: AppTextStyles.pageTitle.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Не удалось загрузить информацию о профиле',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryText.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        children: [
          Text(
            'Мой профиль',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w700,
              fontSize: 26.sp,
              height: 1.149,
              color: const Color(0xFF353F49),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20.h),
          EditableProfileAvatar(
            hasAvatar: _profile?.hasAvatar ?? false,
            name: _profile?.name,
            surname: _profile?.surname,
            size: 120.w,
            onAvatarChanged: _loadProfile,
          ),

          SizedBox(height: 46.h), // Space to menu items
          // Menu items - matching Figma layout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: SvgPicture.asset(
                    'assets/svgs/level_icon.svg',
                    width: 23.w,
                    height: 17.h,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF353F49),
                      BlendMode.srcIn,
                    ),
                  ),
                  title: 'Специализация',
                  onTap: () {
                    if (_profile != null) {
                      context.push(
                        '/my-specializations',
                        extra: _profile!.specializationsWithLevels,
                      );
                    }
                  },
                ),
                SizedBox(height: 16.h),
                FreelancerResumeSection(
                  hasResume: _profile?.hasResume ?? false,
                  resumeFilename: _profile?.resumeFilename,
                  onResumeChanged: _loadProfile,
                ),
                SizedBox(height: 16.h),
                // Commented out for freelancers - only show when user role and permission require them
                /*
                _buildMenuItem(
                  icon: SvgPicture.asset(
                    'assets/svgs/change_pin.svg',
                    width: 14.w,
                    height: 20.h,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF353F49),
                      BlendMode.srcIn,
                    ),
                  ),
                  title: 'Сменить пароль',
                  onTap: () {
                    // TODO: Navigate to change password page
                  },
                ),
                SizedBox(height: 16.h),
                _buildMenuItem(
                  icon: Text(
                    '􁎕',
                    style: TextStyle(
                      fontFamily: 'SF Compact Rounded',
                      fontWeight: FontWeight.w500,
                      fontSize: 20.sp,
                      height: 1.3,
                      color: const Color(0xFF353F49),
                    ),
                  ),
                  title: 'Пройти верификацию',
                  onTap: () {
                    // TODO: Navigate to verification page
                  },
                ),
                SizedBox(height: 16.h),
                */
                _buildLogoutMenuItem(),
                SizedBox(height: 16.h),
                _buildDeleteAccountMenuItem(),
              ],
            ),
          ),

          SizedBox(height: 120.h), // Bottom spacing for tab bar
        ],
      ),
    );
  }

  Widget _buildLogoutMenuItem() {
    return GestureDetector(
      onTap: _isLoggingOut ? null : _handleLogout,
      child: Container(
        width: 354.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side with icon and title
            Row(
              children: [
                // Icon container
                Container(
                  width: 27.w,
                  child: Center(
                    child: _isLoggingOut
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFF15656),
                              ),
                            ),
                          )
                        : SvgPicture.asset(
                            'assets/svgs/exit_icon.svg',
                            width: 20.w,
                            height: 18.h,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFF15656),
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 6.w),
                // Title
                Text(
                  'Выход',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    height: 1.3,
                    color: const Color(0xFFF15656),
                  ),
                ),
              ],
            ),

            // Arrow icon
            Container(
              width: 9.28.w,
              child: SvgPicture.asset(
                'assets/svgs/arrow_icon.svg',
                width: 9.w,
                height: 14.h,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFA9B6B9),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountMenuItem() {
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => const DeleteAccountConfirmModal(),
      ),
      child: Text(
        'Удалить аккаунт',
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
          color: const Color(0xFFD54444),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 354.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side with icon and title
            Row(
              children: [
                // Icon container
                Container(
                  width: 27.w,
                  child: Center(child: icon),
                ),
                SizedBox(width: 6.w),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    height: 1.3,
                    color: const Color(0xFF353F49),
                  ),
                ),
              ],
            ),

            // Arrow icon
            Container(
              width: 9.28.w,
              child: SvgPicture.asset(
                'assets/svgs/arrow_icon.svg',
                width: 9.w,
                height: 14.h,
                colorFilter: ColorFilter.mode(
                  const Color(0xFFA9B6B9),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
