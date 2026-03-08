import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/services/freelancer_onboarding_service.dart';
import '../../../../shared/services/freelancer_portfolio_storage_service.dart';
import '../../../../shared/api/freelancer_api.dart';
import '../../../../shared/di/service_locator.dart';
import '../widgets/gradient_background.dart';
import '../widgets/experience_text_field.dart';

class ExperiencePage extends StatefulWidget {
  final bool isFromSuccessPage;
  final bool isFromMySpecializations;

  const ExperiencePage({
    super.key,
    this.isFromSuccessPage = false,
    this.isFromMySpecializations = false,
  });

  @override
  State<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  FreelancerOnboardingService? _onboardingService;

  final _bioController = TextEditingController();
  final _socialController = TextEditingController();
  final _portfolioController = TextEditingController();
  FreelancerPortfolioStorageService? _portfolioStorageService;

  String? _portfolioFileName;
  bool _hasPortfolioFile = false;
  // ignore: unused_field
  PlatformFile? _selectedPortfolioFile;

  FreelancerOnboardingState _currentState = const FreelancerOnboardingState();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  FreelancerOnboardingService get _service {
    _onboardingService ??= sl<FreelancerOnboardingService>();
    return _onboardingService!;
  }

  // ignore: unused_element
  FreelancerPortfolioStorageService get _portfolioStorage {
    _portfolioStorageService ??= sl<FreelancerPortfolioStorageService>();
    return _portfolioStorageService!;
  }

  Future<void> _loadData() async {
    if (widget.isFromMySpecializations) {
      // When coming from my_specializations, merge existing profile data with new specializations
      // First get the newly selected specializations from current state
      final stateWithNewSpecs = await _service.getCurrentState();

      try {
        // Load the complete existing profile data from API
        final freelancerApi = sl<FreelancerApi>();
        final profile = await freelancerApi.getProfile();

        if (profile.isNotEmpty) {
          // Create state from existing profile data
          final existingProfileState = FreelancerOnboardingState.fromApi(
            profile,
          );

          // Merge existing profile data with new specializations
          _currentState = existingProfileState.copyWith(
            specializationsWithLevels:
                stateWithNewSpecs.specializationsWithLevels,
            hasProfile: true, // Ensure we use PUT request
          );

          // Save the merged state
          await _service.updateState(_currentState);
        } else {
          // Fallback to state with new specs if API fails
          _currentState = stateWithNewSpecs.copyWith(hasProfile: true);
        }
      } catch (_) {
        // Fallback to state with new specs if API fails
        _currentState = stateWithNewSpecs.copyWith(hasProfile: true);
      }
    } else {
      // Original flow for other cases
      final result = await _service.loadPageState(
        isFromSuccessPage: widget.isFromSuccessPage,
      );

      _currentState = result.state;
    }

    _bioController.text = _currentState.bio ?? '';
    _socialController.text = _firstLink(_currentState.socialLinks);
    _portfolioController.text = _firstLink(_currentState.portfolioLinks);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _firstLink(Map<String, dynamic> source) {
    if (source.isEmpty) return '';
    final entry = source.entries.first;
    final value = entry.value;
    return value is String ? value : '';
  }

  Map<String, dynamic> _linksFromInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const <String, dynamic>{};
    }
    return {'website': trimmed};
  }

  Future<void> _persistInputs({String? portfolioFileUrl}) async {
    // Load current accumulated state and update with form inputs
    final currentState = await _service.getCurrentState();
    final portfolioLinks = _linksFromInput(_portfolioController.text);

    if (portfolioFileUrl != null && portfolioFileUrl.isNotEmpty) {
      portfolioLinks['portfolio_file_url'] = portfolioFileUrl;
    }

    final updatedState = currentState.copyWith(
      bio: _bioController.text.trim(),
      socialLinks: _linksFromInput(_socialController.text),
      portfolioLinks: portfolioLinks,
    );

    await _service.updateState(updatedState);
    _currentState = updatedState;
  }

  @override
  void dispose() {
    _bioController.dispose();
    _socialController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    final bio = _bioController.text.trim();

    if (bio.isEmpty) {
      setState(() {
        _errorMessage = 'Добавьте короткое био';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      /* 
      // TODO: add firebase file storage
      String? uploadedPortfolioUrl;
      if (_selectedPortfolioFile?.bytes != null &&
          (_selectedPortfolioFile?.name.isNotEmpty ?? false)) {
        uploadedPortfolioUrl = await _portfolioStorage.uploadPortfolioFile(
          fileBytes: _selectedPortfolioFile!.bytes!,
          fileName: _selectedPortfolioFile!.name,
        );
      }
      */

      // First persist the current inputs to get complete state
      await _persistInputs(portfolioFileUrl: null);

      // Load the complete accumulated state with all form data
      final completeState = await _service.getCurrentState();

      // Create the final payload with the updated bio
      final finalState = completeState.copyWith(bio: bio);

      // Submit using the centralized service
      await _service.submitProfile(finalState);

      if (mounted) {
        if (widget.isFromMySpecializations) {
          // Navigate back to my specializations with success result
          context.go(
            '/my-specializations',
            extra: finalState.specializationsWithLevels,
          );
        } else {
          context.pushReplacementNamed('success');
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickPortfolioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        if (result.files.single.bytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Не удалось прочитать файл, выберите другой.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedPortfolioFile = result.files.single;
          _hasPortfolioFile = true;
          _portfolioFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка выбора файла: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePortfolioFile() {
    setState(() {
      _selectedPortfolioFile = null;
      _hasPortfolioFile = false;
      _portfolioFileName = null;
    });
  }

  Widget _buildPortfolioSection() {
    return _hasPortfolioFile
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/svgs/checkbox_icon.svg',
                      width: 24.w,
                      height: 24.h,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _portfolioFileName ?? 'Файл загружен',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: const Color(0xFF353F49),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _removePortfolioFile,
                  child: Text(
                    'удалить',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 16.sp,
                      color: const Color(0xFFF15656),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            margin: EdgeInsets.only(left: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Или ',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w400,
                        fontSize: 15.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickPortfolioFile,
                      child: Text(
                        'загрузи файл',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp,
                          color: AppColors.blueAccent,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.blueAccent,
                        ),
                      ),
                    ),
                    Text(
                      ' с портфолио',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w400,
                        fontSize: 15.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors.primaryText,
                size: 26.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    if (_currentState.specializationsWithLevels.isEmpty) {
      return Text(
        'Выбранные специализации появятся здесь',
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 17.sp,
          height: 1.3,
          color: const Color(0xFF353F49),
        ),
      );
    }

    final display = _currentState.specializationsWithLevels
        .map((spec) {
          // Check if this is a custom "Other" specialization
          // If the specialization name is not in the constants, it's a custom text
          final displayName = SpecializationConstants.getDisplayNameFromKey(
            spec.specialization,
          );

          // If getDisplayNameFromKey returns the same string, it means it's not a key
          // so it's a custom specialization text
          return displayName == spec.specialization
              ? spec
                    .specialization // Custom text, show as-is
              : displayName; // Standard specialization, show the display name
        })
        .join(', ');

    return Text(
      display,
      style: TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        fontSize: 17.sp,
        height: 1.3,
        color: const Color(0xFF353F49),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: GradientBackground(
          child: Center(
            child: SizedBox(
              width: 32.w,
              height: 32.w,
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.experience_title,
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w700,
                          fontSize: 26.sp,
                          height: 1.149,
                          color: const Color(0xFF353F49),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildTagline(),
                      SizedBox(height: 28.h),
                      ExperienceTextField(
                        labelText: 'Био *',
                        controller: _bioController,
                        maxLines: 6,
                        maxLength: 600,
                        hintText: AppLocalizations.of(
                          context,
                        )!.experience_hint_bio,
                        onChanged: (_) {
                          if (_errorMessage != null) {
                            setState(() {
                              _errorMessage = null;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 18.h),
                      ExperienceTextField(
                        labelText: 'Ссылки на соц. сети',
                        controller: _socialController,
                        maxLines: 3,
                        hintText: AppLocalizations.of(
                          context,
                        )!.experience_hint_social,
                      ),
                      SizedBox(height: 18.h),
                      ExperienceTextField(
                        labelText: 'Ссылки на портфолио',
                        controller: _portfolioController,
                        maxLines: 3,
                        hintText: AppLocalizations.of(
                          context,
                        )!.experience_hint_portfolio,
                      ),
                      SizedBox(height: 18.h),
                      _buildPortfolioSection(),
                      if (_errorMessage != null) ...[
                        SizedBox(height: 20.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w400,
                              fontSize: 17.sp,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 40.h),
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonBackground,
                            foregroundColor: AppColors.buttonText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonBorderRadius,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.verticalPadding,
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: AppColors.white,
                                )
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Отправить заявку',
                                    style: TextStyle(
                                      fontFamily: 'Ubuntu',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
