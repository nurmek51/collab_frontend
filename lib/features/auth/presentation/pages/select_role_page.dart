import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/state/auth.dart';
import '../../../../shared/api/auth_api.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/services/freelancer_profile_status_manager.dart';
import '../../../../shared/di/service_locator.dart';
import '../widgets/gradient_background.dart';

/// Select role page - binds selected role to backend after OTP verification
class SelectRolePage extends StatefulWidget {
  const SelectRolePage({super.key});

  @override
  State<SelectRolePage> createState() => _SelectRolePageState();
}

class _SelectRolePageState extends State<SelectRolePage> {
  late final AuthApi _authApi;
  late final FreelancerOnboardingStore _onboardingStore;
  late final FreelancerProfileStatusManager _statusManager;
  late final AuthStore _authStore;

  String? _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;
  List<String>? _userRoles;

  @override
  void initState() {
    super.initState();
    _authApi = sl<AuthApi>();
    _onboardingStore = sl<FreelancerOnboardingStore>();
    _statusManager = sl<FreelancerProfileStatusManager>();
    _authStore = sl<AuthStore>();
    _loadUserAndRole();
  }

  Future<void> _loadUserAndRole() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch current user info
      final userData = await _authApi.getCurrentUser();
      _userRoles = List<String>.from(userData['roles'] ?? []);

      // Check if user already has a role
      // if (_userRoles!.contains('freelancer') ) {
      //   if (mounted) {
      //     context.pushReplacementNamed('my-work');
      //   }
      //   return;
      // } else if (_userRoles!.contains('client')) {
      //   if (mounted) {
      //     context.pushReplacementNamed('my-orders');
      //   }
      //   return;
      // }

      // If no role, load from onboarding store
      _selectedRole = await _onboardingStore.loadRole();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Auto-submit if role is already selected
        if (_selectedRole != null) {
          _handleRoleSelection();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load user data: ${e.toString()}';
      });
    }
  }

  Future<void> _selectRole(String role) async {
    await _onboardingStore.saveRole(role);
    await _authStore.setRole(role);
    setState(() {
      _selectedRole = role;
    });
    await _handleRoleSelection();
  }

  Future<void> _handleRoleSelection() async {
    if (_selectedRole == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if role is already selected
      if (_userRoles != null && _userRoles!.contains(_selectedRole!)) {
        // Role already exists, ensure it's saved to auth store and navigate
        await _authStore.setRole(_selectedRole!);
        if (mounted) {
          if (_selectedRole == 'freelancer') {
            // Check freelancer profile status via API call (use fresh data for role selection)
            final status = await _statusManager.getProfileStatusFresh();
            if (status == 'pending') {
              context.pushReplacementNamed('success');
              return;
            }

            // Use status manager to get appropriate route for freelancer
            final redirectRoute = await _statusManager.getRedirectRoute();
            if (redirectRoute != null) {
              context.pushReplacementNamed(
                redirectRoute.substring(1),
              ); // Remove leading /
            } else {
              context.pushReplacementNamed(
                'freelancer-form',
              ); // Fallback to form if no profile
            }
          } else {
            context.pushReplacementNamed('my-orders');
          }
        }
        return;
      }

      // Call API to bind role to backend
      await _authApi.selectRole(_selectedRole!);

      if (mounted) {
        // Navigate based on selected role
        if (_selectedRole == 'freelancer') {
          // For new freelancer, check if profile exists and its status (use fresh data)
          try {
            final status = await _statusManager.getProfileStatusFresh();
            if (status == 'pending') {
              context.pushReplacementNamed('success');
              return;
            }
          } catch (e) {
            // Profile doesn't exist yet, proceed with onboarding
          }

          context.pushReplacementNamed('freelancer-form');
        } else {
          // Navigate to client dashboard (My Orders page)
          context.pushReplacementNamed('my-orders');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to set role: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                // Top spacing
                SizedBox(height: 95.h),

                // Logo
                _buildLogo(),

                // Spacing after logo
                SizedBox(height: 36.h),

                // Heading text
                _buildHeadingText(),

                // Spacing before content
                SizedBox(height: 52.h),

                // Loading or role selection
                Expanded(
                  child: _isLoading
                      ? _buildLoadingContent()
                      : _buildRoleSelection(),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  SizedBox(height: 16.h),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.sp,
                      fontFamily: 'Ubuntu',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Bottom spacing
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: AppDimensions.logoWidth,
      height: AppDimensions.logoHeight,
      child: Image.asset('assets/images/collab_logo.png', fit: BoxFit.contain),
    );
  }

  Widget _buildHeadingText() {
    return SizedBox(
      width: 359.w,
      height: 44.h,
      child: Text(
        _isLoading && _selectedRole == null
            ? 'Загружаем данные...'
            : _selectedRole != null
            ? 'Настраиваем ваш профиль...'
            : 'Выберите роль',
        style: AppTextStyles.heading,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 24.h),
          Text(
            _selectedRole == null
                ? 'Загружаем ваш профиль...'
                : 'Подтверждаем роль ${_selectedRole == 'freelancer' ? 'Исполнителя' : 'Заказчика'}...',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 16.sp,
              color: Color.fromRGBO(0, 0, 0, 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        // Freelancer button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _selectRole('freelancer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Войти как Исполнитель',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        height: 1.25,
                      ),
                    ),
                  ),
          ),
        ),

        SizedBox(height: 12.h),

        // Client button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _selectRole('client'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Войти как Заказчик',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        height: 1.25,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
