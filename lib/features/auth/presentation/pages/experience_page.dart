import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/services/freelancer_onboarding_service.dart';
import '../../../../shared/api/freelancer_api.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/utils/resume_file_utils.dart';
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
  FreelancerApi? _freelancerApi;

  final _bioController = TextEditingController();
  final _socialController = TextEditingController();
  final _portfolioController = TextEditingController();

  FreelancerOnboardingState _currentState = const FreelancerOnboardingState();
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isUploadingResume = false;
  bool _isDeletingResume = false;
  double _uploadProgress = 0;
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

  FreelancerApi get _api {
    _freelancerApi ??= sl<FreelancerApi>();
    return _freelancerApi!;
  }

  bool get _hasResume => _currentState.hasResume;

  String? get _resumeFilename => _currentState.resumeFilename;

  Future<void> _loadData() async {
    if (widget.isFromMySpecializations) {
      final stateWithNewSpecs = await _service.getCurrentState();

      try {
        final profile = await _api.getProfile();

        if (profile.isNotEmpty) {
          final existingProfileState = FreelancerOnboardingState.fromApi(
            profile,
          );

          _currentState = existingProfileState.copyWith(
            specializationsWithLevels:
                stateWithNewSpecs.specializationsWithLevels,
            hasProfile: true,
          );

          await _service.updateState(_currentState);
        } else {
          _currentState = stateWithNewSpecs.copyWith(hasProfile: true);
        }
      } catch (_) {
        _currentState = stateWithNewSpecs.copyWith(hasProfile: true);
      }
    } else {
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

  Future<void> _refreshResumeFromProfile() async {
    try {
      final profile = await _api.getProfile();
      if (profile.isEmpty || !mounted) return;

      final resumeState = FreelancerOnboardingState.fromApi(profile);
      setState(() {
        _currentState = _currentState.copyWith(
          hasResume: resumeState.hasResume,
          resumeFilename: resumeState.resumeFilename,
          resumeUploadedAt: resumeState.resumeUploadedAt,
          clearResumeFilename: !resumeState.hasResume,
          clearResumeUploadedAt: !resumeState.hasResume,
        );
      });
      await _service.updateState(_currentState);
    } catch (_) {}
  }

  Future<void> _persistInputs() async {
    final currentState = await _service.getCurrentState();
    final updatedState = currentState.copyWith(
      bio: _bioController.text.trim(),
      socialLinks: _linksFromInput(_socialController.text),
      portfolioLinks: _linksFromInput(_portfolioController.text),
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
      await _persistInputs();

      final completeState = await _service.getCurrentState();
      final finalState = completeState.copyWith(bio: bio);

      await _service.submitProfile(finalState);

      if (mounted) {
        if (widget.isFromMySpecializations) {
          context.go(
            '/my-specializations',
            extra: finalState.specializationsWithLevels,
          );
        } else {
          context.go(AppRouter.successRoute);
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
    if (_isUploadingResume) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: kAllowedResumeExtensions,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final fileName = file.name;
      final bytes = file.bytes;

      if (bytes == null) {
        return;
      }

      final validationError = validateResumeFile(
        fileName: fileName,
        fileSize: bytes.length,
      );
      if (validationError != null) {
        return;
      }

      setState(() {
        _isUploadingResume = true;
        _uploadProgress = 0;
      });

      final uploadResult = await _api.uploadResume(
        fileName: fileName,
        fileBytes: bytes,
        onSendProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _uploadProgress = sent / total);
        },
      );

      if (!mounted) return;

      setState(() {
        _currentState = _currentState.copyWith(
          hasResume: uploadResult.hasResume,
          resumeFilename: uploadResult.resumeFilename,
          resumeUploadedAt: uploadResult.resumeUploadedAt,
        );
        _isUploadingResume = false;
        _uploadProgress = 0;
      });
      await _service.updateState(_currentState);
      await _refreshResumeFromProfile();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isUploadingResume = false;
        _uploadProgress = 0;
      });
    }
  }

  Future<void> _removePortfolioFile() async {
    if (_isDeletingResume || !_hasResume) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить файл?'),
        content: const Text('Файл будет удалён с сервера.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeletingResume = true);
    try {
      await _api.deleteResume();
      if (!mounted) return;

      setState(() {
        _currentState = _currentState.copyWith(
          hasResume: false,
          clearResumeFilename: true,
          clearResumeUploadedAt: true,
        );
        _isDeletingResume = false;
      });
      await _service.updateState(_currentState);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeletingResume = false);
    }
  }

  Widget _buildPortfolioSection() {
    if (_isUploadingResume) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: _uploadProgress > 0 ? _uploadProgress : null,
            color: AppColors.blueAccent,
            backgroundColor: AppColors.blueAccent.withValues(alpha: 0.2),
          ),
          SizedBox(height: 8.h),
          Text(
            'Загрузка файла...',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 15.sp,
              color: AppColors.primaryText,
            ),
          ),
        ],
      );
    }

    return _hasResume
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/checkbox_icon.svg',
                        width: 24.w,
                        height: 24.h,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _resumeFilename ?? 'Файл загружен',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: const Color(0xFF353F49),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _isDeletingResume ? null : _removePortfolioFile,
                  child: Text(
                    _isDeletingResume ? 'удаление...' : 'удалить',
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
          final displayName = SpecializationConstants.getDisplayNameFromKey(
            spec.specialization,
          );

          return displayName == spec.specialization
              ? spec.specialization
              : displayName;
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
                          onPressed: (_isSubmitting || _isUploadingResume)
                              ? null
                              : _submitProfile,
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
