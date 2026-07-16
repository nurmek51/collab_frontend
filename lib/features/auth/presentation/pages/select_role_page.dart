import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/state/auth.dart';
import '../../../../shared/api/auth_api.dart';
import '../../../../shared/api/client.dart';
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
  static String? _pendingRoleSelection;
  static Future<void>? _pendingRoleSelectionRequest;

  late final AuthApi _authApi;
  late final FreelancerOnboardingStore _onboardingStore;
  late final FreelancerProfileStatusManager _statusManager;
  late final AuthStore _authStore;

  String? _selectedRole;
  bool _isLoading = false;
  bool _isHandlingRoleSelection = false;
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
      final userData = await _authApi.getCurrentUser();
      _userRoles = List<String>.from(userData['roles'] ?? []);

      if (mounted) {
        setState(() {
          _selectedRole = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load user data: ${e.toString()}';
      });
    }
  }

  Future<void> _selectRole(String role) async {
    await _onboardingStore.saveRole(role);
    setState(() {
      _selectedRole = role;
    });
    await _handleRoleSelection();
  }

  Future<void> _handleRoleSelection() async {
    if (_selectedRole == null || _isHandlingRoleSelection) return;

    _isHandlingRoleSelection = true;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_userRoles != null && _userRoles!.contains(_selectedRole!)) {
        await _authStore.setRole(_selectedRole!);
        if (mounted) {
          await _navigateForRole(_selectedRole!);
        }
        return;
      }

      await _selectRoleOnce(_selectedRole!);

      if (mounted) {
        await _navigateForRole(_selectedRole!);
      }
    } catch (e) {
      if (_isRoleAlreadySelectedError(e)) {
        await _authStore.setRole(_selectedRole!);
        if (mounted) {
          await _navigateForRole(_selectedRole!);
        }
        return;
      }

      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to set role: ${e.toString()}';
        _isLoading = false;
        _isHandlingRoleSelection = false;
      });
    }
  }

  Future<void> _selectRoleOnce(String role) async {
    final pending = _pendingRoleSelectionRequest;
    if (_pendingRoleSelection == role && pending != null) {
      return pending;
    }

    final request = _authApi.selectRole(role).then<void>((_) {});
    _pendingRoleSelection = role;
    _pendingRoleSelectionRequest = request;

    try {
      await request;
    } finally {
      if (_pendingRoleSelectionRequest == request) {
        _pendingRoleSelection = null;
        _pendingRoleSelectionRequest = null;
      }
    }
  }

  bool _isRoleAlreadySelectedError(Object error) {
    if (error is ApiException) {
      return error.message.toLowerCase().contains('role already exists');
    }

    return error.toString().toLowerCase().contains('role already exists');
  }

  Future<void> _navigateForRole(String role) async {
    if (role == 'freelancer') {
      _statusManager.invalidateCache();
      final redirectRoute = await _statusManager.getRedirectRoute();
      if (!mounted) return;

      if (redirectRoute != null) {
        context.pushReplacementNamed(redirectRoute.substring(1));
      } else {
        context.pushReplacementNamed('freelancer-form');
      }
      return;
    }

    if (mounted) {
      context.pushReplacementNamed('my-orders');
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
