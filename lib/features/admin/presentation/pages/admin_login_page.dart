import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/api/auth_api.dart';

class AdminLoginPage extends StatefulWidget {
  final String? redirectPath;

  const AdminLoginPage({super.key, this.redirectPath});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  late final AuthApi _authApi;

  bool _isLoading = false;
  bool _showOtpField = false;
  String? _errorMessage;

  String get _redirectTarget {
    final redirectPath = widget.redirectPath;
    if (redirectPath == null || redirectPath.isEmpty) {
      return AppRouter.adminRoute;
    }

    final parsedUri = Uri.tryParse(redirectPath);
    final redirectPathOnly = parsedUri?.path ?? redirectPath;
    if (redirectPathOnly == AppRouter.adminLoginRoute ||
        !redirectPathOnly.startsWith(AppRouter.adminRoute)) {
      return AppRouter.adminRoute;
    }

    return redirectPath;
  }

  @override
  void initState() {
    super.initState();
    _authApi = sl<AuthApi>();
    _phoneController.text = '+';
    _checkExistingAuth();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingAuth() async {
    try {
      final isAdmin = await _authApi.isCurrentUserAdmin();
      if (isAdmin && mounted) {
        context.go(_redirectTarget);
      }
    } catch (_) {
      // Not authenticated, stay on login page
    }
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authApi.requestOtp(_phoneController.text.trim());
      if (mounted) {
        setState(() {
          _showOtpField = true;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Ошибка отправки SMS: $error';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authApi.verifyOtp(
        phoneNumber: _phoneController.text.trim(),
        code: _otpController.text.trim(),
      );

      final isAdmin = await _authApi.isCurrentUserAdmin();
      if (!isAdmin) {
        await _authApi.logout();

        if (mounted) {
          setState(() {
            _errorMessage = 'У этой учетной записи нет доступа к админ панели';
            _isLoading = false;
            _showOtpField = false;
            _otpController.clear();
          });
        }
        return;
      }

      if (mounted) {
        context.go(_redirectTarget);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Неверный код: $error';
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _showOtpField = false;
      _errorMessage = null;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Text(
            'Админ панель доступна только на вебе',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppColors.adminPrimaryText,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Вход в админ панель',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: AppColors.adminPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Phone number field
                  TextFormField(
                    controller: _phoneController,
                    enabled: !_showOtpField && !_isLoading,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Номер телефона',
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.adminBackground,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          value.trim() == '+') {
                        return 'Введите номер телефона';
                      }
                      if (!RegExp(
                        r'^\+\d{11,}$',
                      ).hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
                        return 'Неверный формат номера';
                      }
                      return null;
                    },
                  ),

                  if (_showOtpField) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _otpController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'Код из SMS',
                        hintText: '123456',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.adminBackground,
                        counterText: '',
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withAlpha(50)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action buttons
                  if (!_showOtpField) ...[
                    ElevatedButton(
                      onPressed: _isLoading ? null : _requestOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminAccentBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Отправить код',
                              style: TextStyle(
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminAccentBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Войти',
                              style: TextStyle(
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading ? null : _resetForm,
                      child: Text(
                        'Изменить номер',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.adminSecondaryText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
