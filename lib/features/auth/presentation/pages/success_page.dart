import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/help_utils.dart';
import '../../../../shared/services/freelancer_profile_status_manager.dart';
import '../../../../shared/di/service_locator.dart';
import '../widgets/gradient_background.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
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
                // Main content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success illustration
                      _buildSuccessIllustration(),

                      SizedBox(height: 23.h),

                      // Main heading
                      _buildMainHeading(),

                      SizedBox(height: 23.h),

                      // Description text
                      _buildDescriptionText(),

                      SizedBox(height: 42.h),

                      // Fix data button
                      _buildFixDataButton(context),
                    ],
                  ),
                ),

                // Help button at bottom
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
    // Check current profile status before allowing edit (use fresh data)
    try {
      final statusManager = sl<FreelancerProfileStatusManager>();
      final status = await statusManager.getProfileStatusFresh();

      // Only allow editing if status is pending, rejected, or incomplete
      if (status == 'approved') {
        // Already approved, show message instead of navigating
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Ваш профиль уже одобрен. Изменения недоступны.'),
          //     backgroundColor: Colors.green,
          //   ),
          // );
        }
        return;
      }

      // Navigate to freelancer form for editing
      if (mounted) {
        context.pushReplacementNamed(
          'freelancer-form',
          extra: {'isEditMode': true},
        );
      }
    } catch (e) {
      // If there's an error checking status, allow navigation (safer default)
      if (mounted) {
        context.pushReplacementNamed(
          'freelancer-form',
          extra: {'isEditMode': true},
        );
      }
    }
  }

  Future<void> _handleHelpRequest() async {
    await HelpUtils.showSocialLinksModal(context);
  }
}
