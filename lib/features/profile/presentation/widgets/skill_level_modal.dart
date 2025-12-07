import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class SkillLevelModal extends StatefulWidget {
  final String currentLevel;
  final Function(String) onLevelSelected;

  const SkillLevelModal({
    super.key,
    required this.currentLevel,
    required this.onLevelSelected,
  });

  @override
  State<SkillLevelModal> createState() => _SkillLevelModalState();
}

class _SkillLevelModalState extends State<SkillLevelModal> {
  late String _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.currentLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 24.w),
              Text(
                'Опыт',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w700,
                  fontSize: 26.sp,
                  height: 1.149,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(width: 236.w),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ..._buildLevelOptions(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  List<Widget> _buildLevelOptions() {
    final levels = [
      ('junior', 'Junior (до 2 лет)'),
      ('middle', 'Middle (2+ года)'),
      ('senior', 'Senior (5+ лет)'),
    ];

    return levels.map((level) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedLevel = level.$1;
          });
          widget.onLevelSelected(_selectedLevel);
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level.$2,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 15.sp,
                  color: AppColors.primaryText,
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
    }).toList();
  }
}
