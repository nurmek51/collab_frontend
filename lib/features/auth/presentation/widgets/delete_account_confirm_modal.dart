import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/api/auth_api.dart';
import '../../../../shared/di/service_locator.dart';

/// Requires a deliberate typed confirmation before permanently deleting an account.
class DeleteAccountConfirmModal extends StatefulWidget {
  const DeleteAccountConfirmModal({super.key});

  @override
  State<DeleteAccountConfirmModal> createState() =>
      _DeleteAccountConfirmModalState();
}

class _DeleteAccountConfirmModalState extends State<DeleteAccountConfirmModal> {
  static const _confirmationText = 'УДАЛИТЬ';

  final _controller = TextEditingController();
  bool _isDeleting = false;
  String? _errorMessage;

  bool get _canDelete => _controller.text.trim() == _confirmationText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_canDelete || _isDeleting) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await sl<AuthApi>().deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pop();
      context.go('/welcome');
    } catch (_) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _errorMessage = 'Не удалось удалить аккаунт. Попробуйте ещё раз.';
        });
      }
    }
  }

  void _cancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF15656).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_outlined,
                  color: const Color(0xFFF15656),
                  size: 30.w,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Удалить аккаунт?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w700,
                  fontSize: 21.sp,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Это действие нельзя отменить. Будут удалены ваш профиль, файлы, уведомления и связанные данные.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 14.sp,
                  height: 1.35,
                  color: AppColors.primaryText.withValues(alpha: 0.72),
                ),
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Введите «$_confirmationText», чтобы подтвердить',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _controller,
                enabled: !_isDeleting,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _confirmationText,
                  hintStyle: TextStyle(
                    color: AppColors.primaryText.withValues(alpha: 0.35),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.inputBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFF15656)),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 13.sp,
                    color: const Color(0xFFD54444),
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isDeleting ? null : _cancel,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.fromHeight(50.h),
                        side: BorderSide(color: AppColors.inputBorderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text('Отмена'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: _canDelete && !_isDeleting
                          ? _deleteAccount
                          : null,
                      style: FilledButton.styleFrom(
                        minimumSize: Size.fromHeight(50.h),
                        backgroundColor: const Color(0xFFD54444),
                        disabledBackgroundColor: const Color(
                          0xFFF15656,
                        ).withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _isDeleting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Удалить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
