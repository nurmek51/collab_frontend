import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/api/auth_api.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/validation/phone_validation.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/utils/help_utils.dart';
import '../widgets/gradient_background.dart';
import '../widgets/custom_phone_input.dart';

/// Phone number page - second screen in the authentication flow
class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AuthApi _authApi;
  late final FreelancerOnboardingStore _onboardingStore;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authApi = sl<AuthApi>();
    _onboardingStore = sl<FreelancerOnboardingStore>();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Back button and top spacing
                _buildTopSection(),

                // Flexible spacer to center content
                const Spacer(flex: 2),

                // Logo
                _buildLogo(),

                // Spacing after logo
                SizedBox(height: 26.h),

                // Heading text
                _buildHeadingText(),

                // Spacing before input
                SizedBox(height: 29.h),

                // Phone input field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CustomPhoneInput(
                    controller: _phoneController,
                    validator: _validatePhoneNumber,
                    onChanged: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    enabled: !_isLoading,
                  ),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
                  ),
                ],

                // Spacing before button
                SizedBox(height: 21.h),

                // Send code button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildSendCodeButton(),
                ),

                // Flexible spacer to center content
                const Spacer(flex: 2),

                // Help button
                _buildHelpButton(),

                // Bottom spacing
                SizedBox(height: 54.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: EdgeInsets.only(left: 10.w, right: 20.w, top: 16.h),
      child: Row(
        children: [
          SizedBox(width: 12.w, height: 60.h),
          // Back button
          GestureDetector(
            onTap: () => context.go('/welcome'),

            child: Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: SvgPicture.asset(
                'assets/svgs/back_arrow.svg',
                width: 20.w,
                height: 20.h,
              ),
            ),
          ),
          // Spacer to center logo later
          const Expanded(child: SizedBox()),
        ],
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
      'Введите номер телефона',
      style: TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        fontSize: 17.sp,
        height: 1.3,
        color: AppColors.black.withOpacity(0.8),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSendCodeButton() {
    return SizedBox(
      width: 354.w,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          foregroundColor: AppColors.buttonText,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonBorderRadius,
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: AppDimensions.verticalPadding,
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
            : Text(
                AppLocalizations.of(context)!.phone_number_btn_send,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  height: 1.25,
                ),
              ),
      ),
    );
  }

  Widget _buildHelpButton() {
    return GestureDetector(
      onTap: _handleHelpRequest,
      child: Text(
        'Помощь',
        style: TextStyle(
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w500,
          fontSize: 15.sp,
          height: 1.3,
          color: const Color(0xFF2782E3),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    final phoneNumber = PhoneNumber.dirty(value ?? '');
    return phoneNumber.errorMessage;
  }

  Future<void> _handleSendCode() async {
    final phoneNumber = PhoneNumber.dirty(_phoneController.text);

    if (!phoneNumber.isValid) {
      setState(() {
        _errorMessage = phoneNumber.errorMessage;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get normalized phone number
      final normalizedPhone = phoneNumber.normalizedValue;

      // Save phone number for later use
      await _onboardingStore.savePhoneNumber(normalizedPhone);

      // Call API to request OTP
      await _authApi.requestOtp(normalizedPhone);

      // Show success message
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('OTP sent successfully'),
        //     backgroundColor: Colors.green,
        //   ),
        // );

        // Navigate to OTP page
        context.pushNamed('otp', extra: normalizedPhone);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleHelpRequest() async {
    await HelpUtils.showSocialLinksModal(context);
  }
}
