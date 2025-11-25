import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';
import '../../../../shared/api/freelancer_api.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../auth/presentation/widgets/gradient_background.dart';
import '../widgets/skill_level_modal.dart';
import '../widgets/confirm_deletion_modal.dart';

class SpecializationDetailsPage extends StatefulWidget {
  final String specialization;
  final String skillLevel;
  final bool isNew;

  const SpecializationDetailsPage({
    super.key,
    required this.specialization,
    required this.skillLevel,
    required this.isNew,
  });

  @override
  State<SpecializationDetailsPage> createState() =>
      _SpecializationDetailsPageState();
}

class _SpecializationDetailsPageState extends State<SpecializationDetailsPage> {
  late String _selectedSkillLevel;
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _isLoadingData = true; // Add loading state for data
  String? _portfolioFileName;
  bool _hasPortfolioFile = false;

  late FreelancerApi _freelancerApi;

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _behanceController = TextEditingController();

  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _selectedSkillLevel = widget.skillLevel;
    _freelancerApi = sl<FreelancerApi>();
    _loadProfileData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _websiteController.dispose();
    _behanceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final profileResponse = await _freelancerApi.getProfile();
      final socialLinks =
          profileResponse['social_links'] as Map<String, dynamic>?;
      final portfolioLinks =
          profileResponse['portfolio_links'] as Map<String, dynamic>?;

      final resolvedLevel = _resolveSkillLevel(profileResponse);
      final existingFileLink = portfolioLinks?['file']?.toString().trim();

      setState(() {
        _profileData = profileResponse;
        _bioController.text = profileResponse['bio'] ?? '';
        _websiteController.text =
            (socialLinks?['website'] ?? socialLinks?['instagram'] ?? '')
                .toString();
        _behanceController.text =
            (portfolioLinks?['behance'] ?? portfolioLinks?['website'] ?? '')
                .toString();

        if (resolvedLevel != null && resolvedLevel.isNotEmpty) {
          _selectedSkillLevel = resolvedLevel;
        }

        if (existingFileLink != null && existingFileLink.isNotEmpty) {
          _hasPortfolioFile = true;
          _portfolioFileName = existingFileLink.split(RegExp(r'[\\/]')).last;
        } else {
          _hasPortfolioFile = false;
          _portfolioFileName = null;
        }

        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      // Handle error silently
    }
  }

  String? _resolveSkillLevel(Map<String, dynamic> profileResponse) {
    final specs =
        profileResponse['specializations_with_levels'] as List<dynamic>?;
    if (specs == null) {
      return null;
    }

    // Convert the display name (e.g., "Маркетолог общего профиля") to the key (e.g., "general_marketer")
    final specKey = SpecializationConstants.getKeyFromDisplayName(
      widget.specialization,
    );

    for (final spec in specs) {
      if (spec is! Map<String, dynamic>) continue;
      final rawSpecialization = spec['specialization']?.toString();
      if (rawSpecialization == null) continue;
      // Match against the API key format
      if (rawSpecialization == specKey) {
        final level = (spec['level'] ?? spec['skill_level'])?.toString();
        if (level != null && level.isNotEmpty) {
          return level;
        }
      }
    }

    return null;
  }

  Future<void> _saveChanges() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_profileData == null) {
        throw Exception('Profile data not loaded');
      }

      final currentSpecs =
          (_profileData!['specializations_with_levels'] as List<dynamic>?)
              ?.map(
                (spec) => SpecializationWithLevel.fromJson(
                  spec as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [];

      // Get the key format of the specialization for comparison
      final specKey = SpecializationConstants.getKeyFromDisplayName(
        widget.specialization,
      );

      List<SpecializationWithLevel> updatedSpecs;

      if (widget.isNew) {
        // For new specializations, add it to the list
        final existingSpecIndex = currentSpecs.indexWhere((spec) {
          final specKeyToCompare =
              SpecializationConstants.getKeyFromDisplayName(
                spec.specialization,
              );
          return specKeyToCompare == specKey;
        });

        if (existingSpecIndex >= 0) {
          // Update existing spec if found
          updatedSpecs = currentSpecs.map((spec) {
            final specKeyToCompare =
                SpecializationConstants.getKeyFromDisplayName(
                  spec.specialization,
                );
            if (specKeyToCompare == specKey) {
              return spec.copyWith(skillLevel: _selectedSkillLevel);
            }
            return spec;
          }).toList();
        } else {
          // Add new spec if not found
          final newSpec = SpecializationWithLevel(
            specialization: widget.specialization,
            skillLevel: _selectedSkillLevel,
          );
          updatedSpecs = [...currentSpecs, newSpec];
        }
      } else {
        // For existing specializations, just update the skill level
        updatedSpecs = currentSpecs.map((spec) {
          final specKeyToCompare =
              SpecializationConstants.getKeyFromDisplayName(
                spec.specialization,
              );
          if (specKeyToCompare == specKey) {
            return spec.copyWith(skillLevel: _selectedSkillLevel);
          }
          return spec;
        }).toList();
      }

      final updatedSocialLinks = Map<String, dynamic>.from(
        (_profileData!['social_links'] as Map<String, dynamic>?) ?? {},
      );
      final websiteLink = _websiteController.text.trim();
      if (websiteLink.isEmpty) {
        updatedSocialLinks.remove('website');
      } else {
        updatedSocialLinks['website'] = websiteLink;
      }
      updatedSocialLinks.removeWhere(
        (key, value) => value is String && value.trim().isEmpty,
      );

      final updatedPortfolioLinks = Map<String, dynamic>.from(
        (_profileData!['portfolio_links'] as Map<String, dynamic>?) ?? {},
      );
      final behanceLink = _behanceController.text.trim();
      if (behanceLink.isEmpty) {
        updatedPortfolioLinks.remove('behance');
      } else {
        updatedPortfolioLinks['behance'] = behanceLink;
      }

      if (_hasPortfolioFile) {
        updatedPortfolioLinks['file'] = _portfolioFileName ?? '';
      } else {
        updatedPortfolioLinks.remove('file');
      }
      updatedPortfolioLinks.removeWhere(
        (key, value) => value is String && value.trim().isEmpty,
      );

      final updatedState = FreelancerOnboardingState(
        iin: _profileData!['iin'] ?? '',
        city: _profileData!['city'] ?? '',
        email: _profileData!['email'] ?? '',
        name: _profileData!['name'] ?? '',
        surname: _profileData!['surname'] ?? '',
        phoneNumber: _profileData!['phone_number'] ?? '',
        bio: _bioController.text.trim(),
        specializationsWithLevels: updatedSpecs,
        socialLinks: updatedSocialLinks,
        portfolioLinks: updatedPortfolioLinks,
        paymentInfo: _profileData!['payment_info'] ?? {},
        avatarUrl: _profileData!['avatar_url'],
      );

      await _freelancerApi.updateProfile(updatedState);

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSpecialization() async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => ConfirmDeletionModal(
          isLoading: _isDeleting,
          onCancelPressed: () {},
          onDeletePressed: () async {
            setDialogState(() {});
            setState(() {
              _isDeleting = true;
            });

            try {
              if (_profileData == null) {
                throw Exception('Profile data not loaded');
              }

              final currentSpecs =
                  (_profileData!['specializations_with_levels']
                          as List<dynamic>?)
                      ?.map(
                        (spec) => SpecializationWithLevel.fromJson(
                          spec as Map<String, dynamic>,
                        ),
                      )
                      .toList() ??
                  [];

              final specKey = SpecializationConstants.getKeyFromDisplayName(
                widget.specialization,
              );

              final filteredSpecs = currentSpecs.where((spec) {
                final specKeyToCompare =
                    SpecializationConstants.getKeyFromDisplayName(
                      spec.specialization,
                    );
                return specKeyToCompare != specKey;
              }).toList();

              final updatedState = FreelancerOnboardingState(
                iin: _profileData!['iin'] ?? '',
                city: _profileData!['city'] ?? '',
                email: _profileData!['email'] ?? '',
                name: _profileData!['name'] ?? '',
                surname: _profileData!['surname'] ?? '',
                phoneNumber: _profileData!['phone_number'] ?? '',
                bio: _profileData!['bio'] ?? '',
                specializationsWithLevels: filteredSpecs,
                socialLinks: _profileData!['social_links'] ?? {},
                portfolioLinks: _profileData!['portfolio_links'] ?? {},
                paymentInfo: _profileData!['payment_info'] ?? {},
                avatarUrl: _profileData!['avatar_url'],
              );

              await _freelancerApi.updateProfile(updatedState);

              // Give the API time to process the update
              await Future.delayed(const Duration(milliseconds: 500));

              if (mounted) {
                // Close the dialog first with true result
                // ignore: use_build_context_synchronously
                Navigator.of(dialogContext).pop(true);
              }
            } catch (e) {
              if (mounted) {
                // Show error and close dialog with false
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка удаления: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
                // ignore: use_build_context_synchronously
                Navigator.of(dialogContext).pop(false);
              }
            } finally {
              if (mounted) {
                setState(() {
                  _isDeleting = false;
                });
              }
            }
          },
        ),
      ),
    );

    if (confirmed != true) return;

    // After successful deletion, redirect to freelancer profile page and replace current route
    if (mounted) {
      context.go('/freelancer-profile');
    }
  }

  Future<void> _pickPortfolioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        setState(() {
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
      _hasPortfolioFile = false;
      _portfolioFileName = null;
    });
  }

  void _showSkillLevelModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SkillLevelModal(
        currentLevel: _selectedSkillLevel,
        onLevelSelected: (selectedLevel) {
          setState(() {
            _selectedSkillLevel = selectedLevel;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildSpecializationTitle(),
                      SizedBox(height: 24.h),
                      _buildBioField(),
                      SizedBox(height: 24.h),
                      _buildSocialLinksFields(),
                      SizedBox(height: 24.h),
                      _buildSkillLevelSection(),
                      SizedBox(height: 10.h),
                      _buildPortfolioSection(),
                      SizedBox(height: 32.h),
                      _buildDeleteButton(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              _buildSaveButton(),
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
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: SvgPicture.asset(
              'assets/svgs/back_arrow.svg',
              width: 24.w,
              height: 24.h,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryText,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationTitle() {
    return Text(
      SpecializationConstants.getDisplayNameFromKey(widget.specialization),
      style: TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w700,
        fontSize: 26.sp,
        height: 1.149,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildBioField() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: _isLoadingData
          ? _buildLoadingField(height: 100.h)
          : TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Работал там и сям. Опыт такой и сякой',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryText.withValues(alpha: 0.6),
                ),
              ),
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 15.sp,
                color: AppColors.primaryText,
              ),
            ),
    );
  }

  Widget _buildLoadingField({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(
          255,
          0,
          125,
          250,
        ).withValues(alpha: 0), // Transparent color
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppColors.primaryText,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLinksFields() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: _isLoadingData
              ? _buildLoadingField(height: 20.h)
              : TextField(
                  controller: _websiteController,
                  decoration: InputDecoration(
                    hintText: 'https://linkedin.com/in/username',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryText.withValues(alpha: 0.6),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 15.sp,
                    color: AppColors.primaryText,
                  ),
                ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: _isLoadingData
              ? _buildLoadingField(height: 20.h)
              : TextField(
                  controller: _behanceController,
                  decoration: InputDecoration(
                    hintText: 'https://behance.net/username',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryText.withValues(alpha: 0.6),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 15.sp,
                    color: AppColors.primaryText,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSkillLevelSection() {
    return GestureDetector(
      onTap: _isLoadingData ? null : _showSkillLevelModal,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: _isLoadingData
            ? _buildLoadingField(height: 20.h)
            : Row(
                children: [
                  SvgPicture.asset(
                    'assets/svgs/level_icon.svg',
                    width: 24.w,
                    height: 24.h,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryText,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _getSkillLevelDisplay(_selectedSkillLevel),
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w400,
                        fontSize: 15.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/svgs/mini-arrow_icon.svg',
                    width: 9.28.w,
                    height: 16.84.h,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryText,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
      ),
    );
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

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _isDeleting ? null : _deleteSpecialization,
      child: Container(
        width: double.infinity,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(4.w),
        child: Text(
          _isDeleting ? 'Удаление...' : 'Удалить роль',
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20.w),
      child: ElevatedButton(
        onPressed: (_isLoading || _isLoadingData) ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: (_isLoading || _isLoadingData)
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Сохранить',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }

  String _getSkillLevelDisplay(String level) {
    switch (level.toLowerCase()) {
      case 'junior':
        return 'Junior (до 2 лет)';
      case 'middle':
        return 'Middle (2+ года)';
      case 'senior':
        return 'Senior (5+ лет)';
      default:
        return level;
    }
  }
}
