import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/di/service_locator.dart';
import '../widgets/gradient_background.dart';

/// Welcome page - first screen in the authentication flow
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String? _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;
  late final FreelancerOnboardingStore _onboardingStore;

  @override
  void initState() {
    super.initState();
    _onboardingStore = sl<FreelancerOnboardingStore>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: kIsWeb
              ? ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: _buildContent(isWeb: true),
                  ),
                )
              : _buildContent(isWeb: false),
        ),
      ),
    );
  }

  Widget _buildContent({required bool isWeb}) {
    return Column(
      mainAxisSize: isWeb ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // Top spacer for balance
        if (!isWeb) const Spacer(flex: 1),
        if (isWeb) SizedBox(height: 80.h),

        // Logo
        _buildLogo(),

        // Spacing after logo
        SizedBox(height: 26.h),

        // Heading text
        _buildHeadingText(),

        // Spacing before image
        SizedBox(height: 30.h),

        // Image
        _buildImage(),

        // Flexible spacer - takes up remaining space on mobile
        if (!isWeb) const Spacer(flex: 1),
        if (isWeb) SizedBox(height: 40.h),

        // Role buttons
        _buildRoleButtons(),

        // Error message
        if (_errorMessage != null) ...[
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontFamily: 'Ubuntu',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        // Bottom spacing
        SizedBox(height: 28.h),
      ],
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: double.infinity,
      child: Image.asset(
        'assets/images/temp.png',
        fit: BoxFit.fitWidth,
        width: double.infinity,
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
    return Text(
      AppLocalizations.of(context)!.welcome_title,
      style: AppTextStyles.heading,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRoleButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Freelancer button
          SizedBox(
            width: 354.w,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _handleRoleSelection('freelancer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: _isLoading && _selectedRole == 'freelancer'
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.welcome_btn_specialist,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        height: 1.25,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 12.h),

          // Client button
          SizedBox(
            width: 354.w,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _handleRoleSelection('client'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: _isLoading && _selectedRole == 'client'
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.welcome_btn_employer,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        height: 1.25,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRoleSelection(String role) async {
    setState(() {
      _selectedRole = role;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Save selected role locally (do not call API yet)
      await _onboardingStore.saveRole(role);

      // Navigate to phone number page for authentication
      if (mounted) {
        context.pushNamed('phone-number');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save role selection. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
