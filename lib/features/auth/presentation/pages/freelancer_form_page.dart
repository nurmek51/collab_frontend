import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/services/freelancer_onboarding_service.dart';
import '../../../../shared/di/service_locator.dart';
import '../widgets/gradient_background.dart';
import '../widgets/custom_text_field.dart';

class FreelancerFormPage extends StatefulWidget {
  final bool isFromSuccessPage;

  const FreelancerFormPage({super.key, this.isFromSuccessPage = false});

  @override
  State<FreelancerFormPage> createState() => _FreelancerFormPageState();
}

class _FreelancerFormPageState extends State<FreelancerFormPage> {
  FreelancerOnboardingService? _onboardingService;

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _iinController = TextEditingController();

  bool _isLoading = true;
  bool _isEditMode = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  FreelancerOnboardingService get _service {
    _onboardingService ??= sl<FreelancerOnboardingService>();
    return _onboardingService!;
  }

  Future<void> _loadInitialData() async {
    // Load state using the centralized service
    final result = await _service.loadPageState(
      isFromSuccessPage: widget.isFromSuccessPage,
    );

    _isEditMode = result.isEditMode;
    _applyState(result.state);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyState(FreelancerOnboardingState state) {
    _nameController.text = state.name ?? '';
    _surnameController.text = state.surname ?? '';
    _emailController.text = state.email ?? '';
    _cityController.text = state.city ?? '';
    _iinController.text = state.iin ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _iinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: GradientBackground(
          child: Center(
            child: SizedBox(
              width: 32.w,
              height: 32.w,
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    bottom: AppDimensions.buttonHeight + 120.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h),
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, bottom: 32.h),
                        child: Text(
                          AppLocalizations.of(context)!.freelancer_form_title,
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w700,
                            fontSize: 26.sp,
                            height: 1.149,
                            color: const Color(0xFF353F49),
                          ),
                        ),
                      ),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Имя',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[а-яА-Яa-zA-Z\s-]'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _surnameController,
                        label: 'Фамилия',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[а-яА-Яa-zA-Z\s-]'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _cityController,
                        label: 'Город',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[а-яА-Яa-zA-Z\s-]'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _iinController,
                        label: 'ИИН',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        SizedBox(height: 16.h),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            height: 1.3,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonBackground,
                        foregroundColor: AppColors.buttonText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.buttonBorderRadius,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.verticalPadding,
                        ),
                      ),
                      child: Text(
                        'Продолжить',
                        style: AppTextStyles.buttonText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return CustomTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: (_) {
        if (_errorMessage != null) {
          setState(() {
            _errorMessage = null;
          });
        }
      },
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _validateAllFields({
    required String name,
    required String surname,
    required String email,
    required String city,
    required String iin,
  }) {
    if (name.isEmpty) {
      _setErrorMessage('Имя обязательно');
      return false;
    }

    if (name.length < 2) {
      _setErrorMessage('Имя должно содержать минимум 2 символа');
      return false;
    }

    if (surname.isEmpty) {
      _setErrorMessage('Фамилия обязательна');
      return false;
    }

    if (surname.length < 2) {
      _setErrorMessage('Фамилия должна содержать минимум 2 символа');
      return false;
    }

    if (email.isEmpty) {
      _setErrorMessage('Email обязателен');
      return false;
    }

    if (!_isValidEmail(email)) {
      _setErrorMessage('Введите корректный email (например: user@example.com)');
      return false;
    }

    if (city.isEmpty) {
      _setErrorMessage('Город обязателен');
      return false;
    }

    if (city.length < 2) {
      _setErrorMessage('Город должен содержать минимум 2 символа');
      return false;
    }

    if (iin.isEmpty) {
      _setErrorMessage('ИИН обязателен');
      return false;
    }

    if (iin.length != 12) {
      _setErrorMessage('ИИН должен содержать ровно 12 цифр');
      return false;
    }

    if (!RegExp(r'^\d{12}$').hasMatch(iin)) {
      _setErrorMessage('ИИН должен содержать только цифры');
      return false;
    }

    return true;
  }

  void _setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _persistFields() async {
    // Load current accumulated state and update with form inputs
    final currentState = await _service.getCurrentState();
    final updatedState = currentState.copyWith(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      email: _emailController.text.trim(),
      city: _cityController.text.trim(),
      iin: _iinController.text.trim(),
    );

    await _service.updateState(updatedState);
  }

  Future<void> _handleContinue() async {
    setState(() {
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();
    final city = _cityController.text.trim();
    final iin = _iinController.text.trim();

    if (!_validateAllFields(
      name: name,
      surname: surname,
      email: email,
      city: city,
      iin: iin,
    )) {
      return;
    }

    try {
      await _persistFields();
      if (mounted) {
        if (_isEditMode) {
          context.pushNamed('specializations', extra: {'isEditMode': true});
        } else {
          context.pushNamed('specializations');
        }
      }
    } catch (error) {
      if (mounted) {
        _setErrorMessage('Ошибка при сохранении данных: ${error.toString()}');
      }
    }
  }
}
