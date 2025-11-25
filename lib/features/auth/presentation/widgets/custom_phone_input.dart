import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Custom phone input field matching Figma design
class CustomPhoneInput extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;
  final bool enabled;

  const CustomPhoneInput({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<CustomPhoneInput> createState() => _CustomPhoneInputState();
}

class _CustomPhoneInputState extends State<CustomPhoneInput> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 354.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _hasError ? Colors.red : const Color(0xFFCADDE1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: Row(
          children: [
            // Phone input field
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                enabled: widget.enabled,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 24.sp,
                  height: 1.149,
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '+7 000 000 0000',
                  hintStyle: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 24.sp,
                    height: 1.149,
                    color: const Color(0xFFBCC5C7),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-\(\)]')),
                  _PhoneNumberFormatter(),
                ],
                validator: (value) {
                  final result = widget.validator?.call(value);
                  setState(() {
                    _hasError = result != null;
                  });
                  return result;
                },
                onChanged: (value) {
                  widget.onChanged?.call();
                  // Clear error state when user starts typing
                  if (_hasError) {
                    setState(() {
                      _hasError = false;
                    });
                  }
                },
              ),
            ),

            // Clear button (when there's text)
            if (widget.controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged?.call();
                },
                child: Container(
                  width: 26.w,
                  height: 26.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Phone number formatter to automatically format input
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Remove all non-digit characters except +
    String digitsOnly = text.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it starts with +
    if (digitsOnly.isNotEmpty && !digitsOnly.startsWith('+')) {
      digitsOnly = '+$digitsOnly';
    }

    // Format based on length
    String formatted = '';
    if (digitsOnly.length > 1) {
      // Extract country code and number
      final countryAndNumber = digitsOnly.substring(1);

      if (countryAndNumber.isNotEmpty) {
        // Assume +7 format for Russian numbers
        if (digitsOnly.startsWith('+7') && countryAndNumber.length > 1) {
          formatted = '+7';
          final number = countryAndNumber.substring(1);

          if (number.isNotEmpty) {
            // Format as +7 XXX XXX XXXX
            for (int i = 0; i < number.length && i < 10; i++) {
              if (i == 0) formatted += ' ';
              if (i == 3 || i == 6) formatted += ' ';
              formatted += number[i];
            }
          }
        } else {
          // For other country codes, just add spaces every 3 digits
          formatted = '+';
          for (int i = 0; i < countryAndNumber.length; i++) {
            if (i > 0 && i % 3 == 0) formatted += ' ';
            formatted += countryAndNumber[i];
          }
        }
      } else {
        formatted = '+';
      }
    } else {
      formatted = digitsOnly;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
