import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/onboarding_wrapper.dart';

class ClientOnboardingPageTwo extends StatefulWidget {
  const ClientOnboardingPageTwo({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<ClientOnboardingPageTwo> createState() =>
      _ClientOnboardingPageTwoState();
}

class _ClientOnboardingPageTwoState extends State<ClientOnboardingPageTwo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _staggeredControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    // Main controller for overall coordination
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create staggered animation controllers for the 3 sections
    _staggeredControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    // Fade animations for each section
    _fadeAnimations = _staggeredControllers
        .map(
          (controller) => Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    // Slide animations from left to right
    _slideAnimations = _staggeredControllers
        .map(
          (controller) => Tween<Offset>(
            begin: const Offset(-0.5, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    // Start animations with staggered delay
    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    const delayBetweenAnimations = Duration(milliseconds: 200);

    for (int i = 0; i < _staggeredControllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: i * delayBetweenAnimations.inMilliseconds),
        () {
          if (mounted) {
            _staggeredControllers[i].forward();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _staggeredControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAnimatedSection({
    required int index,
    required String title,
    required String description,
    required double topPosition,
  }) {
    return Positioned(
      left: 32.w,
      right: 32.w,
      top: topPosition,
      child: AnimatedBuilder(
        animation: _staggeredControllers[index],
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      fontSize: 33.sp,
                      height: 1.09,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      height: 1.3,
                      color: const Color(0xFF353F49),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingWrapper(
      child: SizedBox.expand(
        child: Stack(
          children: [
            // First section - "Без найма в штат"
            _buildAnimatedSection(
              index: 0,
              title: 'Без найма в штат',
              description:
                  'Сотрудничайте в проектном формате — без лишних формальностей и долгих процедур.',
              topPosition: 102.h,
            ),

            // Second section - "Оптимизация расходов"
            _buildAnimatedSection(
              index: 1,
              title: 'Оптимизация расходов',
              description:
                  'Работайте по договорам — платите только за результат, без дополнительных расходов.',
              topPosition: 262.h,
            ),

            // Third section - "Проверенные специалисты"
            _buildAnimatedSection(
              index: 2,
              title: 'Проверенные специалисты',
              description:
                  'Все исполнители проходят модерацию и подтверждают опыт. Вы работаете только с теми, кому можно доверять.',
              topPosition: 470.h,
            ),

            // Main action button - "Начать работу"
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 50.h,
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: widget.onNext,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Начать работу',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 17.sp,
                      height: 1.149,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
