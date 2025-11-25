import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/freelancer_flow_exports.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../features/auth/presentation/widgets/gradient_background.dart';

/// Payments coming soon page matching Figma design
/// Shows a loading indicator and "Скоро будет" message
class PaymentsSoonPage extends StatefulWidget {
  const PaymentsSoonPage({super.key});

  @override
  State<PaymentsSoonPage> createState() => _PaymentsSoonPageState();
}

class _PaymentsSoonPageState extends State<PaymentsSoonPage>
    with FreelancerPageMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with title
              _buildHeader(false),

              // Main content area
              Expanded(child: _buildMainContent()),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header matching FreelancerProfilePage style
  Widget _buildHeader(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'История выплат',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w700,
              fontSize: 26.sp,
              height: 1.149,
              color: const Color(0xFF353F49),
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/freelancer-profile'),
            child: Icon(
              Icons.account_circle_outlined,
              size: 29.w,
              color: const Color(0xFF517499),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content with loading indicator and coming soon text
  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading spinner with SVG icon
          _buildLoadingSpinner(),

          SizedBox(height: 32.h),

          // "Скоро будет" text matching screenshot styling
          Text(
            'Скоро будет',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 24.sp,
              height: 1.2,
              color: AppColors.primaryText.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the loading spinner with SVG icon
  Widget _buildLoadingSpinner() {
    return SvgPicture.asset(
      'assets/svgs/soon_icon.svg',
      width: 80.w,
      height: 80.h,
    );
  }
}
