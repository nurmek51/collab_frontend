import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/services/freelancer_onboarding_service.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/widgets/full_width_separator.dart';
import '../widgets/gradient_background.dart';
import '../widgets/skill_level_radio_group.dart';

class SpecializationLevelsPage extends StatefulWidget {
  const SpecializationLevelsPage({super.key});

  @override
  State<SpecializationLevelsPage> createState() =>
      _SpecializationLevelsPageState();
}

class _SpecializationLevelsPageState extends State<SpecializationLevelsPage>
    with TickerProviderStateMixin {
  // Animation controller for sticky button
  late AnimationController _buttonAnimationController;
  late Animation<Offset> _buttonSlideAnimation;

  FreelancerOnboardingService? _onboardingService;

  // Selected specializations and their levels
  List<SpecializationWithLevel> _selectedSpecializations = [];
  final Map<String, String> _skillLevels = {};

  // Available skill levels
  final List<Map<String, String>> _availableLevels = [
    {'key': 'junior', 'title': 'Начальный'},
    {'key': 'middle', 'title': 'Средний'},
    {'key': 'senior', 'title': 'Продвинутый'},
  ];

  FreelancerOnboardingService get _service {
    _onboardingService ??= sl<FreelancerOnboardingService>();
    return _onboardingService!;
  }

  @override
  void initState() {
    super.initState();

    // Initialize button animation
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // Load specializations and initialize skill levels
    _loadSpecializations();
  }

  Future<void> _loadSpecializations() async {
    final state = await _service.getCurrentState();
    if (mounted) {
      setState(() {
        _selectedSpecializations = state.specializationsWithLevels;

        // Initialize skill levels for each specialization
        for (final spec in _selectedSpecializations) {
          _skillLevels[spec.specialization] = spec.skillLevel ?? '';
        }

        _checkButtonVisibility();
      });
    }
  }

  void _checkButtonVisibility() {
    final allLevelsSelected = _skillLevels.values.every(
      (level) => level.isNotEmpty,
    );
    if (allLevelsSelected) {
      _buttonAnimationController.forward();
    } else {
      _buttonAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _updateSkillLevel(String specialization, String level) {
    setState(() {
      _skillLevels[specialization] = level;
      _checkButtonVisibility();
    });

    // Save updated specializations with levels
    _saveSpecializationsWithLevels();
  }

  Future<void> _saveSpecializationsWithLevels() async {
    // Load current accumulated state and update with skill levels
    final currentState = await _service.getCurrentState();
    final updatedSpecs = _selectedSpecializations.map((spec) {
      return spec.copyWith(skillLevel: _skillLevels[spec.specialization] ?? '');
    }).toList();

    final updatedState = currentState.copyWith(
      specializationsWithLevels: updatedSpecs,
    );

    await _service.updateState(updatedState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Header with back button
                  _buildHeader(),

                  // Main heading
                  _buildMainHeading(),

                  // Subtitle
                  _buildSubtitle(),

                  // Scrollable specializations list with level selection
                  Expanded(child: _buildSpecializationsList()),

                  // Bottom spacing for sticky button
                  SizedBox(height: 100.h),
                ],
              ),

              // Sticky continue button
              _buildStickyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.w,
              height: 40.h,
              child: Icon(
                Icons.arrow_back_ios,
                color: const Color(0xFF353F49),
                size: 26.sp,
              ),
            ),
          ),

          // Progress indicator (this is step 3 of 4)
          Text(
            '3/4',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 20.sp,
              height: 1.149,
              color: const Color(0xFFBCC5C7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeading() {
    return Padding(
      padding: EdgeInsets.only(left: 22.w, right: 22.w, bottom: 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context)!.specialization_levels_title,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w700,
            fontSize: 26.sp,
            height: 1.149,
            color: const Color(0xFF353F49),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: EdgeInsets.only(left: 22.w, right: 22.w, bottom: 21.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context)!.specialization_levels_subtitle,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            height: 1.3,
            color: const Color(0xFF353F49).withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecializationsList() {
    return SingleChildScrollView(
      // Remove horizontal padding to allow separators to be full-width
      child: Column(
        children: [
          // Build specialization sections with level selectors
          ..._selectedSpecializations.asMap().entries.map((entry) {
            final index = entry.key;
            final spec = entry.value;
            final isLast = index == _selectedSpecializations.length - 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Specialization title with horizontal padding
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ).copyWith(left: 22.w, bottom: 15.h),
                  child: Text(
                    spec.specialization,
                    softWrap: true,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      fontSize: 17.sp,
                      height: 1.149,
                      color: const Color(0xFF353F49),
                    ),
                  ),
                ),

                // Skill level radio group with horizontal padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SkillLevelRadioGroup(
                    selectedLevel: _skillLevels[spec.specialization] ?? '',
                    onLevelChanged: (level) =>
                        _updateSkillLevel(spec.specialization, level),
                    availableLevels: _availableLevels,
                  ),
                ),

                // Add separator between specializations (except for the last one)
                // Separator is now full-width since it's not constrained by scroll view padding
                if (!isLast) ...[
                  SizedBox(height: 18.h),
                  const FullWidthSeparator(),
                  SizedBox(height: 23.h),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStickyButton() {
    final allLevelsSelected = _skillLevels.values.every(
      (level) => level.isNotEmpty,
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !allLevelsSelected,
        child: Container(
          padding: EdgeInsets.all(20.w),
          height: AppDimensions.buttonHeight + 40.h,
          child: AnimatedBuilder(
            animation: _buttonAnimationController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Subtle gradient overlay that appears with button
                  Positioned.fill(
                    child: Opacity(
                      opacity: _buttonAnimationController.value * 0.3,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.backgroundColor.withOpacity(0.2),
                              AppColors.backgroundColor.withOpacity(0.4),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Button with slide animation
                  Center(
                    child: SlideTransition(
                      position: _buttonSlideAnimation,
                      child: Opacity(
                        opacity: _buttonAnimationController.value,
                        child: Container(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.buttonBorderRadius,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  0.16 * _buttonAnimationController.value,
                                ),
                                offset: const Offset(0, 10),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: allLevelsSelected
                                ? _handleContinue
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBackground,
                              foregroundColor: AppColors.buttonText,
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
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Отправить заявку',
                                style: AppTextStyles.buttonText,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    // Check if all levels are selected
    if (_skillLevels.values.any((level) => level.isEmpty)) {
      return;
    }

    // Save the final specializations with levels
    await _saveSpecializationsWithLevels();

    if (mounted) {
      context.pushNamed('experience');
    }
  }
}
