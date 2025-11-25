import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/services/freelancer_onboarding_service.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/gradient_background.dart';
import '../widgets/specialization_checkbox.dart';

/// Specializations selection page - second step in freelancer registration
class SpecializationsPage extends StatefulWidget {
  final bool isFromSuccessPage;
  final bool isFromMySpecializations;

  const SpecializationsPage({
    super.key,
    this.isFromSuccessPage = false,
    this.isFromMySpecializations = false,
  });

  @override
  State<SpecializationsPage> createState() => _SpecializationsPageState();
}

class _SpecializationsPageState extends State<SpecializationsPage>
    with TickerProviderStateMixin {
  // Animation controller for sticky button
  late AnimationController _buttonAnimationController;
  late Animation<Offset> _buttonSlideAnimation;
  FreelancerOnboardingService? _onboardingService;

  // Selected specializations and their levels
  List<SpecializationWithLevel> _selectedSpecializations = [];
  Map<String, String> _skillLevels = {};

  // Track custom text for "Other" specialization separately
  // Key: specialization name, Value: custom text (only for "Другое")
  Map<String, String> _customTexts = {};

  // All available specializations from constants
  final List<Map<String, String>> _specializations =
      SpecializationConstants.availableSpecializations;

  // Available skill levels (same as in specialization_levels_page)
  final List<Map<String, String>> _availableLevels = [
    {'key': 'junior', 'title': 'Начальный (1-2 года)'},
    {'key': 'middle', 'title': 'Средний (2+ года)'},
    {'key': 'senior', 'title': 'Продвинутый (5+ лет)'},
  ];

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

    // Load saved specializations asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedSpecializations();
    });
  }

  FreelancerOnboardingService get _service {
    _onboardingService ??= sl<FreelancerOnboardingService>();
    return _onboardingService!;
  }

  // Check if a specialization is a custom "Other" (not in constants)
  bool _isCustomSpecialization(String specialization) {
    return !SpecializationConstants.isStandardSpecialization(specialization);
  }

  // Load previously saved specializations if available
  Future<void> _loadSavedSpecializations() async {
    try {
      final state = await _service.getCurrentState();
      if (state.specializationsWithLevels.isNotEmpty) {
        setState(() {
          // Process loaded specializations and detect custom "Other" ones
          for (final spec in state.specializationsWithLevels) {
            if (_isCustomSpecialization(spec.specialization)) {
              // This is a custom "Other" specialization
              // Add "Другое" to the list and store the custom text separately
              _selectedSpecializations.add(
                SpecializationWithLevel(
                  specialization: 'Другое',
                  skillLevel: spec.skillLevel,
                ),
              );
              _skillLevels['Другое'] = spec.skillLevel ?? '';
              _customTexts['Другое'] =
                  spec.specialization; // Store the custom text
            } else {
              // Standard specialization - add as-is
              _selectedSpecializations.add(spec);
              _skillLevels[spec.specialization] = spec.skillLevel ?? '';
            }
          }
        });

        // Check button visibility after loading completes
        _checkButtonVisibility();
      }
    } catch (e) {
      // Silently fail if loading fails - user can start fresh
    }
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _toggleSpecialization(String key) {
    setState(() {
      final specName = _specializations.firstWhere(
        (s) => s['key'] == key,
      )['title']!;

      if (_selectedSpecializations.any((s) => s.specialization == specName)) {
        // Deselect: remove the specialization
        _selectedSpecializations.removeWhere(
          (s) => s.specialization == specName,
        );
        _skillLevels.remove(specName);
        _customTexts.remove(specName); // Clear custom text if it exists
      } else {
        // Select: check limit and add
        if (_selectedSpecializations.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Можно выбрать максимум 5 специализаций',
                style: TextStyle(fontFamily: 'Ubuntu', fontSize: 14.sp),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _selectedSpecializations.add(
          SpecializationWithLevel(specialization: specName),
        );
        _skillLevels[specName] = '';
      }

      _saveSpecializations();
      _checkButtonVisibility();
    });
  }

  void _updateSkillLevel(String specialization, String level) {
    setState(() {
      _skillLevels[specialization] = level;
      _checkButtonVisibility();
    });

    // Save updated specializations with levels
    _saveSpecializationsWithLevels();
  }

  void _checkButtonVisibility() {
    // Button should be visible when at least one specialization is selected
    // and all selected specializations have skill levels
    final hasSelections = _selectedSpecializations.isNotEmpty;
    final allLevelsSelected = _selectedSpecializations.every(
      (spec) => _skillLevels[spec.specialization]?.isNotEmpty == true,
    );

    if (hasSelections && allLevelsSelected) {
      _buttonAnimationController.forward();
    } else {
      _buttonAnimationController.reverse();
    }
  }

  Future<void> _saveSpecializationsWithLevels() async {
    // Load current accumulated state and update with specializations
    final currentState = await _service.getCurrentState();
    final updatedSpecs = _selectedSpecializations.map((spec) {
      // If this is "Другое" and user has entered custom text, use the custom text
      final displayName =
          spec.specialization == 'Другое' && _customTexts.containsKey('Другое')
          ? _customTexts['Другое']!
          : spec.specialization;

      return SpecializationWithLevel(
        specialization: displayName,
        skillLevel: _skillLevels[spec.specialization] ?? '',
      );
    }).toList();

    final updatedState = currentState.copyWith(
      specializationsWithLevels: updatedSpecs,
    );

    await _service.updateState(updatedState);
  }

  Future<void> _saveSpecializations() async {
    await _saveSpecializationsWithLevels();
  }

  void _updateCustomSpecialization(String value) {
    setState(() {
      // Always store the custom text for "Другое"
      if (value.isNotEmpty) {
        _customTexts['Другое'] = value;
      } else {
        _customTexts.remove('Другое');
      }
    });

    // Save the updated specialization with custom text
    _saveSpecializationsWithLevels();
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
                  // Header with back button and progress
                  _buildHeader(),

                  // Main heading
                  _buildMainHeading(),

                  // Scrollable specializations list
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

          // Progress indicator
          Text(
            '2/4',
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
      padding: EdgeInsets.only(left: 22.w, right: 22.w, bottom: 29.h),
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

  Widget _buildSpecializationsList() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Specialization checkboxes with level dropdowns
          ..._specializations.map((spec) {
            final specName = spec['title']!;
            final isSelected = _selectedSpecializations.any(
              (s) => s.specialization == specName,
            );

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: SpecializationCheckbox(
                title: specName,
                isSelected: isSelected,
                onTap: () => _toggleSpecialization(spec['key']!),
                selectedLevel: _skillLevels[specName],
                onLevelChanged: (level) => _updateSkillLevel(specName, level),
                availableLevels: _availableLevels,
                showLevelDropdown: isSelected,
              ),
            );
          }),

          // Custom input for "Other" option
          if (_selectedSpecializations.any(
            (s) => s.specialization == 'Другое',
          )) ...[
            SizedBox(height: 8.h),
            CustomSpecializationInput(
              value: _customTexts['Другое'] ?? '',
              onChanged: _updateCustomSpecialization,
              isVisible: true,
            ),
          ],

          // Bottom spacing
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildStickyButton() {
    final hasSelections = _selectedSpecializations.isNotEmpty;
    final allLevelsSelected = _selectedSpecializations.every(
      (spec) => _skillLevels[spec.specialization]?.isNotEmpty == true,
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !hasSelections || !allLevelsSelected,
        child: Container(
          padding: EdgeInsets.all(20.w),
          height:
              AppDimensions.buttonHeight +
              40.h, // Reserve space for button + padding
          child: AnimatedBuilder(
            animation: _buttonAnimationController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Subtle gradient overlay that appears with button
                  Positioned.fill(
                    child: Opacity(
                      opacity:
                          _buttonAnimationController.value *
                          0.3, // Much more transparent
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.gradientEnd.withOpacity(0.2),
                              AppColors.gradientEnd.withOpacity(0.4),
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
                          width: 354.w,
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
                            onPressed: (hasSelections && allLevelsSelected)
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
                            child: Text(
                              'Продолжить',
                              style: AppTextStyles.buttonText,
                              textAlign: TextAlign.center,
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
    final hasSelections = _selectedSpecializations.isNotEmpty;
    final allLevelsSelected = _selectedSpecializations.every(
      (spec) => _skillLevels[spec.specialization]?.isNotEmpty == true,
    );

    // Check if all conditions are met
    if (!hasSelections || !allLevelsSelected) {
      return;
    }

    // Save the final specializations with levels
    await _saveSpecializationsWithLevels();

    if (mounted) {
      // Navigate directly to experience page (skipping specialization-levels)
      if (widget.isFromSuccessPage || widget.isFromMySpecializations) {
        context.pushNamed(
          'experience',
          extra: {
            'isEditMode': true,
            'isFromMySpecializations': widget.isFromMySpecializations,
          },
        );
      } else {
        context.pushNamed('experience');
      }
    }
  }
}
