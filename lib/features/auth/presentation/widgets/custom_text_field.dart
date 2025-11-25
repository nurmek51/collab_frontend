import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.keyboardType,
    this.enabled = true,
    this.inputFormatters,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFCADDE1), width: 1.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: keyboardType,
                    enabled: enabled,
                    inputFormatters: inputFormatters,
                    readOnly: readOnly,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 17.sp,
                      height: 1.149,
                      color: AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: label,
                      hintStyle: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w400,
                        fontSize: 17.sp,
                        height: 1.149,
                        color: const Color(0xFFBCC5C7),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
