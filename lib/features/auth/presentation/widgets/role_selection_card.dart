import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

/// Role selection card widget matching Figma design
class RoleSelectionCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectionCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 168.w,
        height: 198.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? AppColors.black : const Color(0xFFCADDE1),
            width: isSelected ? 3.0 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            // Image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 169.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),

            // Title
            Positioned(
              bottom: 17.h,
              left: 0,
              right: 0,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  height: 1.3,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Check mark for selected state
            if (isSelected)
              Positioned(
                top: 6.h,
                right: 9.w,
                child: Container(
                  width: 25.w,
                  height: 28.h,
                  decoration: const BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: AppColors.white, size: 16.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Role selection widget with both cards
class RoleSelectionWidget extends StatelessWidget {
  final String? selectedRole;
  final Function(String) onRoleSelected;

  const RoleSelectionWidget({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: RoleSelectionCard(
            title: 'Я – заказчик',
            imagePath: 'assets/images/briefcase_icon.png',
            isSelected: selectedRole == 'CLIENT',
            onTap: () => onRoleSelected('CLIENT'),
          ),
        ),
        SizedBox(width: 18.w),
        Flexible(
          child: RoleSelectionCard(
            title: 'Я – исполнитель',
            imagePath: 'assets/images/laptop_icon.png',
            isSelected: selectedRole == 'FREELANCER',
            onTap: () => onRoleSelected('FREELANCER'),
          ),
        ),
      ],
    );
  }
}
