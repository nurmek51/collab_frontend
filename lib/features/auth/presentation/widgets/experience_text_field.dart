import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class ExperienceTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? hintText;

  const ExperienceTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
    this.maxLength,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 354.w,
      constraints: BoxConstraints(minHeight: maxLines > 1 ? 60.h : 100.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFCADDE1), width: 1.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: maxLength != null
              ? [LengthLimitingTextInputFormatter(maxLength)]
              : null,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w400,
            fontSize: 17.sp,
            height: 1.3,
            color: const Color(0xFF353F49),
          ),
          decoration: InputDecoration(
            hintText: hintText ?? labelText,
            hintStyle: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 17.sp,
              height: 1.3,
              color: const Color(0xFFBCC5C7),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            counterText: '',
          ),
        ),
      ),
    );
  }
}
