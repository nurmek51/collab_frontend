import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/specialization_constants.dart';
import '../../../../../shared/api/applications_api.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../data/models/vacancy_application_models.dart';

/// Enhanced modal widget for selecting available specializations with vacancy support
class VacancySelectionModal extends StatefulWidget {
  final String orderId;
  final Function(AvailableSpecialization) onSpecializationSelected;

  const VacancySelectionModal({
    super.key,
    required this.orderId,
    required this.onSpecializationSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String orderId,
    required Function(AvailableSpecialization) onSpecializationSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      showDragHandle: false,
      elevation: 0,
      useRootNavigator: true,
      builder: (context) => VacancySelectionModal(
        orderId: orderId,
        onSpecializationSelected: onSpecializationSelected,
      ),
    );
  }

  @override
  State<VacancySelectionModal> createState() => _VacancySelectionModalState();
}

class _VacancySelectionModalState extends State<VacancySelectionModal> {
  late final ApplicationsApi _applicationsApi;
  List<AvailableSpecialization> availableSpecializations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _applicationsApi = sl<ApplicationsApi>();
    _loadAvailableSpecializations();
  }

  Future<void> _loadAvailableSpecializations() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final specializations = await _applicationsApi
          .getAvailableSpecializations(widget.orderId);

      final availableSpecializations = specializations
          .where((spec) => !spec.isOccupied)
          .toList();

      if (mounted) {
        setState(() {
          this.availableSpecializations = availableSpecializations;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text(
              'Выберите специализацию',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
                color: AppColors.primaryText,
              ),
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? _buildErrorState()
                : availableSpecializations.isEmpty
                ? _buildEmptyState()
                : _buildSpecializationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ошибка загрузки специализаций',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          ElevatedButton(
            onPressed: _loadAvailableSpecializations,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Text(
        'Нет доступных специализаций',
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: AppColors.primaryText,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSpecializationsList() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: availableSpecializations.map((specialization) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _VacancyItem(
                specialization: specialization,
                onTap: () => widget.onSpecializationSelected(specialization),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Individual vacancy item widget
class _VacancyItem extends StatelessWidget {
  final AvailableSpecialization specialization;
  final VoidCallback onTap;

  const _VacancyItem({required this.specialization, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayName = SpecializationConstants.getDisplayNameFromKey(
      specialization.specialization,
    );
    final skillLevel = specialization.skillLevel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 354.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$displayName ($skillLevel)',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          height: 1.3,
                          color: AppColors.primaryText,
                        ),
                      ),
                      if (specialization.requirements != null &&
                          specialization.requirements!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            specialization.requirements!,
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              height: 1.2,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 19.72.w,
                  color: const Color(0xFFA9B6B9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
