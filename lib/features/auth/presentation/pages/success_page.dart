import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/guards/freelancer_profile_guard.dart';
import '../../../../shared/services/freelancer_profile_status_manager.dart';
import '../../../../shared/state/auth.dart';
import '../../../../shared/utils/help_utils.dart';
import '../widgets/gradient_background.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> with WidgetsBindingObserver {
  Timer? _statusPollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncRouteWithProfileStatus();
    _statusPollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _syncRouteWithProfileStatus(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusPollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncRouteWithProfileStatus();
    }
  }

  Future<void> _syncRouteWithProfileStatus() async {
    final authStore = sl<AuthStore>();
    if (!await authStore.isAuthenticated()) {
      if (mounted) context.go('/');
      return;
    }

    final role = await authStore.getRole();
    if (role != 'freelancer') {
      if (mounted) context.go('/');
      return;
    }

    final statusManager = sl<FreelancerProfileStatusManager>();
    final status = await statusManager.getProfileStatusFresh();
    if (!mounted) return;

    switch (status) {
      case 'approved':
        context.go(AppRouter.myWorkRoute);
        return;
      case 'pending':
        return;
      default:
        final redirect = await sl<FreelancerProfileGuard>().getRequiredRedirect();
        if (!mounted || redirect == null || redirect == AppRouter.successRoute) {
          return;
        }
        context.go(redirect);
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSuccessIllustration(),
                      SizedBox(height: 23.h),
                      _buildMainHeading(),
                      SizedBox(height: 23.h),
                      _buildDescriptionText(),
                      SizedBox(height: 42.h),
                      _buildFixDataButton(context),
                    ],
                  ),
                ),
                _buildHelpButton(),
                SizedBox(height: 49.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIllustration() {
    return Container(
      width: 260.w,
      height: 162.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.68.r),
        image: const DecorationImage(
          image: AssetImage('assets/images/success_illustration.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMainHeading() {
    return Text(
      AppLocalizations.of(context)!.success_title,
      style: TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w700,
        fontSize: 26.sp,
        height: 1.149,
        color: const Color(0xFF000000),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescriptionText() {
    return Text(
      AppLocalizations.of(context)!.success_subtitle,
      style: TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        fontSize: 17.sp,
        height: 1.3,
        color: const Color(0xFF000000),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFixDataButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleFixData(context),
      child: Text(
        AppLocalizations.of(context)!.success_btn_edit,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          height: 1.3,
          color: const Color(0xFF2782E3),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHelpButton() {
    return GestureDetector(
      onTap: _handleHelpRequest,
      child: Text(
        'Помощь',
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          height: 1.3,
          color: const Color(0xFF2782E3),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _handleFixData(BuildContext context) async {
    if (!mounted) return;

    try {
      final statusManager = sl<FreelancerProfileStatusManager>();
      final status = await statusManager.getProfileStatusFresh();

      if (!mounted || status == 'approved') return;

      context.pushReplacementNamed(
        'freelancer-form',
        extra: {'isEditMode': true},
      );
    } catch (_) {
      if (!mounted) return;
      context.pushReplacementNamed(
        'freelancer-form',
        extra: {'isEditMode': true},
      );
    }
  }

  Future<void> _handleHelpRequest() async {
    await HelpUtils.showSocialLinksModal(context);
  }
}
