import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/animations/animation_constants.dart';

/// Unified bottom tab bar for all freelancer flow pages
/// Provides consistent navigation experience across the freelancer journey
class UnifiedFreelancerBottomTabBar extends StatefulWidget {
  final int currentIndex;
  final EdgeInsetsGeometry? margin;

  const UnifiedFreelancerBottomTabBar({
    super.key,
    required this.currentIndex,
    this.margin,
  });

  @override
  State<UnifiedFreelancerBottomTabBar> createState() =>
      _UnifiedFreelancerBottomTabBarState();
}

class _UnifiedFreelancerBottomTabBarState
    extends State<UnifiedFreelancerBottomTabBar>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late AnimationController _iconAnimationController;
  late AnimationController _containerAnimationController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _containerScaleAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: AnimationConstants.medium,
      vsync: this,
    );

    _iconAnimationController = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
    );

    _containerAnimationController = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
    );

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: AnimationConstants.smoothCurve,
    );

    _iconScaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: AnimationConstants.iconActiveScale,
        ).animate(
          CurvedAnimation(
            parent: _iconAnimationController,
            curve: AnimationConstants.bounceGentle,
          ),
        );

    _containerScaleAnimation =
        Tween<double>(begin: 1.0, end: AnimationConstants.tabBarScale).animate(
          CurvedAnimation(
            parent: _containerAnimationController,
            curve: AnimationConstants.smoothCurve,
          ),
        );

    _backgroundAnimationController.forward();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _iconAnimationController.dispose();
    _containerAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(UnifiedFreelancerBottomTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _iconAnimationController.forward().then((_) {
        _iconAnimationController.reverse();
      });
      _containerAnimationController.forward().then((_) {
        _containerAnimationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundAnimation,
        _containerScaleAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _containerScaleAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _backgroundAnimation.value)),
            child: Opacity(
              opacity: _backgroundAnimation.value,
              child: Container(
                margin:
                    widget.margin ??
                    EdgeInsets.only(
                      left: isSmallScreen ? 15.w : 20.w,
                      right: isSmallScreen ? 15.w : 20.w,
                      bottom: isSmallScreen ? 20.h : 34.h,
                    ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 35.r : 40.r,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.09 * _backgroundAnimation.value,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.w : 10.w,
                    vertical: isSmallScreen ? 4.h : 6.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabItem(
                        context: context,
                        index: 0,
                        iconWidget: _buildHomeIcon(),
                        label: 'Главная',
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 1,
                        iconWidget: SvgPicture.asset(
                          'assets/svgs/my_work_icon.svg',
                          width: 26.w,
                          height: 22.h,
                          colorFilter: ColorFilter.mode(
                            widget.currentIndex == 1
                                ? AppColors.black
                                : AppColors.black.withValues(alpha: 0.7),
                            BlendMode.srcIn,
                          ),
                        ),
                        label: 'Моя работа',
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 2,
                        iconWidget: SvgPicture.asset(
                          'assets/svgs/payments_icon.svg',
                          width: 25.w,
                          height: 18.h,
                          colorFilter: ColorFilter.mode(
                            widget.currentIndex == 2
                                ? AppColors.black
                                : AppColors.black.withValues(alpha: 0.7),
                            BlendMode.srcIn,
                          ),
                        ),
                        label: 'Выплаты',
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildTabItem(
                        context: context,
                        index: 3,
                        iconWidget: SvgPicture.asset(
                          'assets/svgs/profile_icon.svg',
                          width: 19.w,
                          height: 20.h,
                          colorFilter: ColorFilter.mode(
                            widget.currentIndex == 3
                                ? AppColors.black
                                : AppColors.black.withValues(alpha: 0.7),
                            BlendMode.srcIn,
                          ),
                        ),
                        label: 'Профиль',
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the home icon with proper positioning from Figma design
  Widget _buildHomeIcon() {
    return SizedBox(
      width: 22.w,
      height: 20.h,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: SvgPicture.asset(
              'assets/svgs/home_icon_left.svg',
              width: 13.33.w,
              height: 20.h,
              colorFilter: ColorFilter.mode(
                widget.currentIndex == 0
                    ? AppColors.black
                    : AppColors.black.withValues(alpha: 0.7),
                BlendMode.srcIn,
              ),
            ),
          ),
          Positioned(
            left: 8.67.w,
            top: 0,
            child: SvgPicture.asset(
              'assets/svgs/home_icon_right.svg',
              width: 13.33.w,
              height: 20.h,
              colorFilter: ColorFilter.mode(
                widget.currentIndex == 0
                    ? AppColors.black
                    : AppColors.black.withValues(alpha: 0.7),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual tab item with proper spacing and interaction
  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required Widget iconWidget,
    required String label,
    required bool isSmallScreen,
  }) {
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: AnimatedBuilder(
        animation: _iconScaleAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: AnimationConstants.medium,
                curve: Curves.easeInOutCubic,
                width: isSelected ? (isSmallScreen ? 70.w : 84.w) : 0,
                height: isSelected ? (isSmallScreen ? 48.h : 56.h) : 0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEBF6F9)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 88.r : 98.r,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onTabTap(context, index),
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 88.r : 98.r,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 5.84.w : 7.84.w,
                      vertical: isSmallScreen ? 3.88.h : 5.88.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          duration: AnimationConstants.fast,
                          scale: isSelected && widget.currentIndex == index
                              ? _iconScaleAnimation.value
                              : 1.0,
                          child: SizedBox(child: iconWidget),
                        ),
                        SizedBox(height: isSmallScreen ? 0.78.h : 0.98.h),
                        AnimatedDefaultTextStyle(
                          duration: AnimationConstants.fast,
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 8.sp : 10.sp,
                            height: 1.176,
                            color: isSelected
                                ? AppColors.black
                                : AppColors.black.withValues(alpha: 0.7),
                          ),
                          child: Text(label),
                        ),
                        SizedBox(height: isSmallScreen ? 4.86.h : 6.86.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Handles navigation when tab is tapped
  /// Uses GoRouter for consistent navigation throughout the app
  void _onTabTap(BuildContext context, int index) {
    if (widget.currentIndex == index) return;

    switch (index) {
      case 0:
        context.go('/feed');
        break;
      case 1:
        context.go('/my-work');
        break;
      case 2:
        context.go('/payments');
        break;
      case 3:
        context.go('/freelancer-profile');
        break;
    }
  }
}
