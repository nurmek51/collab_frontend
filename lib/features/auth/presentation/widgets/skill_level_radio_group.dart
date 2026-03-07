import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

/// Skill level radio group widget matching Figma design
class SkillLevelRadioGroup extends StatelessWidget {
  final String selectedLevel;
  final Function(String) onLevelChanged;
  final List<Map<String, String>> availableLevels;

  const SkillLevelRadioGroup({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
    required this.availableLevels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: availableLevels.map((level) {
        final isSelected = selectedLevel == level['key'];
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: SkillLevelRadioItem(
            title: level['title']!,
            isSelected: isSelected,
            onTap: () => onLevelChanged(level['key']!),
          ),
        );
      }).toList(),
    );
  }
}

/// Individual skill level radio item widget
class SkillLevelRadioItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SkillLevelRadioItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            // Custom radio button
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.black : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.black : const Color(0xFFADC1C5),
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: AppColors.white, size: 16.sp)
                  : null,
            ),

            SizedBox(width: 10.w),

            // Title text
            Expanded(
              child: Text(
                title,
                softWrap: true,
                maxLines: null,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  height: 1.3,
                  color: const Color(0xFF353F49),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
