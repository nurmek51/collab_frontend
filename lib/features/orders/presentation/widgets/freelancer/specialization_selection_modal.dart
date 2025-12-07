import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/specialization_constants.dart';
import '../../../data/models/specialization_offer_model.dart';

/// Modal widget for selecting a specialization when multiple options are available
class SpecializationSelectionModal extends StatelessWidget {
  final List<SpecializationOfferModel> specializations;
  final Function(SpecializationOfferModel) onSpecializationSelected;

  const SpecializationSelectionModal({
    super.key,
    required this.specializations,
    required this.onSpecializationSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<SpecializationOfferModel> specializations,
    required Function(SpecializationOfferModel) onSpecializationSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      showDragHandle: false,
      elevation: 0,
      useRootNavigator: true, // Ensures modal overlays tab bar
      builder: (context) => SpecializationSelectionModal(
        specializations: specializations,
        onSpecializationSelected: onSpecializationSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360.h,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            // Header section
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Выберите оффер',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      fontSize: 21.sp,
                      height: 1.149,
                      color: AppColors.primaryText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.w,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 31.h),

            // Specializations list
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: specializations.map((specialization) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _SpecializationItem(
                        title: SpecializationConstants.getDisplayNameFromKey(
                          specialization.specialization,
                        ),
                        onTap: () => onSpecializationSelected(specialization),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual specialization item widget
class _SpecializationItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SpecializationItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 354.w,
        height: 62.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  height: 1.3,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 19.72.w,
              color: const Color(0xFFA9B6B9),
            ),
          ],
        ),
      ),
    );
  }
}
