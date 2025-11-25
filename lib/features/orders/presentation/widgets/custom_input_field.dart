import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Custom input field widget matching Figma design
class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final bool isTextArea;
  final bool readOnly;
  final bool enabled;

  const CustomInputField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.isTextArea = false,
    this.readOnly = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isTextArea) {
      return Container(
        width: 354.w,
        height: 100.h,
        padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.inputBorderColor, width: 1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          enabled: enabled,
          style: AppTextStyles.textAreaPlaceholder.copyWith(
            color: AppColors.primaryText,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTextStyles.textAreaPlaceholder,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 10.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.inputBorderColor, width: 1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  validator: validator,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  enabled: enabled,
                  style: AppTextStyles.inputLabel.copyWith(
                    color: AppColors.primaryText,
                  ),
                  decoration: InputDecoration(
                    hintText: label,
                    hintStyle: AppTextStyles.inputLabel,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              // Icon placeholder (invisible for now)
              // Container(
              //   width: 26.w,
              //   height: 26.h,
              //   decoration: const BoxDecoration(color: Color(0xFFD9D9D9)),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
