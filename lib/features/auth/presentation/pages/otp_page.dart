import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/api/auth_api.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/validation/otp_validation.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/utils/help_utils.dart';
import '../widgets/gradient_background.dart';
import '../widgets/improved_otp_input.dart';

/// OTP page - third screen in the authentication flow
class OtpPage extends StatefulWidget {
  final String? phoneNumber;
  final String? selectedRole;

  const OtpPage({super.key, this.phoneNumber, this.selectedRole});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late final AuthApi _authApi;
  late final FreelancerOnboardingStore _onboardingStore;

  String _otpCode = '';
  String? _phoneNumber;
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _hasAutoSubmitted = false; // Track if we've already auto-submitted once
  String? _errorMessage;
  OtpCode _otpValidation = const OtpCode.pure();

  // Timer for resend functionality
  Timer? _resendTimer;
  int _resendCountdown = 80; // 01:20 = 80 seconds
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _authApi = sl<AuthApi>();
    _onboardingStore = sl<FreelancerOnboardingStore>();
    _loadData();
    _startResendTimer();
  }

  Future<void> _loadData() async {
    // Load phone number and role from storage or navigation
    _phoneNumber =
        widget.phoneNumber ?? await _onboardingStore.loadPhoneNumber();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 80;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _formattedCountdown {
    final minutes = _resendCountdown ~/ 60;
    final seconds = _resendCountdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
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

              // Spacing before OTP inputs
              SizedBox(height: 23.h),

              // OTP input fields
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 354.w, maxHeight: 68.h),
                  child: ImprovedOtpInput(
                    onCompleted: _handleOtpCompleted,
                    onChanged: (otp) {
                      setState(() {
                        _otpCode = otp;
                        _otpValidation = OtpCode.dirty(otp);
                        _errorMessage = null;
                      });
                    },
                    isVerifying: _isVerifying,
                  ),
                ),
              ),

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

              // Spacing before button
              SizedBox(height: 21.h),

              // Continue button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildContinueButton(),
              ),

              // Spacing before resend
              SizedBox(height: 21.h),

              // Resend label
              Text(
                AppLocalizations.of(context)!.otp_label_resend,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  height: 1.3,
                  color: AppColors.black.withOpacity(0.3),
                ),
                textAlign: TextAlign.center,
              ),

              // SizedBox(height: 2.h),

              // Resend code button and countdown (always visible)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Resend button (always visible, inactive during countdown)
                  GestureDetector(
                    onTap: _canResend ? _handleResendCode : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.otp_btn_resend,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w500,
                            fontSize: 15.sp,
                            height: 1.3,
                            color: _canResend
                                ? const Color(0xFF2782E3)
                                : AppColors.black.withOpacity(0.3),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: 4.w),
                        // Countdown timer on the right - hidden when countdown ends
                        if (_resendCountdown > 0)
                          Text(
                            '($_formattedCountdown)',
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              height: 1.3,
                              color: AppColors.black.withOpacity(0.3),
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ],
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
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 16.h),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.black.withOpacity(0.8),
                size: 18.sp,
                semanticLabel: 'Go back to phone number page',
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
      'Введите код из СМС',
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

  Widget _buildContinueButton() {
    final isEnabled = _otpValidation.isComplete && !_isLoading && !_isVerifying;

    return SizedBox(
      width: 354.w,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleVerifyOtp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.buttonBackground
              : Colors.grey[300],
          foregroundColor: isEnabled ? AppColors.buttonText : Colors.grey[600],
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
        child: (_isLoading || _isVerifying)
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isEnabled ? Colors.white : Colors.grey[600]!,
                  ),
                ),
              )
            : Text(
                _isVerifying ? 'Проверяем...' : 'Продолжить',
                style: AppTextStyles.buttonText.copyWith(
                  color: isEnabled ? Colors.white : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }

  Widget _buildHelpButton() {
    return GestureDetector(
      onTap: _handleHelpRequest,
      child: Text(
        'Не получается войти?',
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

  Future<void> _handleOtpCompleted(String otp) async {
    setState(() {
      _otpCode = otp;
      _otpValidation = OtpCode.dirty(otp);
    });

    // Auto-submit only once per session, and only if not currently loading/verifying
    if (_otpValidation.isComplete &&
        !_hasAutoSubmitted &&
        !(_isLoading || _isVerifying)) {
      _hasAutoSubmitted = true; // Mark as auto-submitted
      await _handleVerifyOtp();
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (!_otpValidation.isComplete) {
      setState(() {
        _errorMessage =
            _otpValidation.errorMessage ??
            'Please enter the complete 4-digit code';
      });
      return;
    }

    if (_phoneNumber == null) {
      setState(() {
        _errorMessage = 'Phone number not found. Please go back and try again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // Call API to verify OTP and get tokens
      await _authApi.verifyOtp(phoneNumber: _phoneNumber!, code: _otpCode);

      if (mounted) {
        // Navigate to role selection page
        context.pushReplacementNamed('select-role');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (!_canResend || _phoneNumber == null) return;

    try {
      // Call API to resend OTP
      await _authApi.requestOtp(_phoneNumber!);

      // Restart timer
      _startResendTimer();

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Code sent successfully'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleHelpRequest() async {
    await HelpUtils.showSocialLinksModal(context);
  }
}
