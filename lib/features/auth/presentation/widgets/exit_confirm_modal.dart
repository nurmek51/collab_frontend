import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/di/service_locator.dart';
import '../../domain/usecases/logout.dart';

class ExitConfirmModal extends StatefulWidget {
  final VoidCallback? onCancelPressed;

  const ExitConfirmModal({super.key, this.onCancelPressed});

  @override
  State<ExitConfirmModal> createState() => _ExitConfirmModalState();
}

class _ExitConfirmModalState extends State<ExitConfirmModal> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logoutUseCase = sl<Logout>();
      await logoutUseCase.call();

      if (mounted) {
        Navigator.of(context).pop(true);
        context.go('/welcome');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выходе: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleCancel() {
    widget.onCancelPressed?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: GestureDetector(
        onTap: _isLoading
            ? null
            : () {
                _handleCancel();
              },
        child: Material(
          color: Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: GestureDetector(
              onTap:
                  () {}, // Prevent dismissing when tapping on the modal itself
              child: Container(
                width: MediaQuery.of(context).size.width - 40.w,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF15656).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'svgs/exit_confirm_icon.svg',
                            width: 28.w,
                            height: 28.w,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Title
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Вы уверены, что хотите выйти?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w500,
                            fontSize: 20.sp,
                            color: AppColors.primaryText,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Buttons
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isLoading ? null : _handleCancel,
                                borderRadius: BorderRadius.circular(12.r),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Отмена',
                                      style: TextStyle(
                                        fontFamily: 'Ubuntu',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.sp,
                                        color: AppColors.primaryText,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Logout button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isLoading ? null : _handleLogout,
                                borderRadius: BorderRadius.circular(12.r),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF15656),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 20.h,
                                            width: 20.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.w,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(AppColors.white),
                                            ),
                                          )
                                        : Text(
                                            'Выйти',
                                            style: TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.sp,
                                              color: AppColors.white,
                                              height: 1.2,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
