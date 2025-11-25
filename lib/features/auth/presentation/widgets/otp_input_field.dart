import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

/// Single OTP input field widget matching Figma design
class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onChanged;
  final VoidCallback? onCompleted;
  final bool isLast;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onCompleted,
    this.isLast = false,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.4.w,
      height: 67.16.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.79.r),
        border: Border.all(color: const Color(0xFFCADDE1), width: 1.05),
      ),
      child: Center(
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 24.sp,
            color: AppColors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (widget.isLast) {
                widget.onCompleted?.call();
              } else {
                // Move to next field
                FocusScope.of(context).nextFocus();
              }
            } else {
              // Move to previous field if backspace on empty field
              FocusScope.of(context).previousFocus();
            }
            widget.onChanged?.call();
          },
          onTap: () {
            // Clear the field when tapped
            widget.controller.clear();
          },
        ),
      ),
    );
  }
}

/// Complete OTP input widget with 4 fields
class OtpInputWidget extends StatefulWidget {
  final Function(String) onCompleted;
  final Function(String)? onChanged;

  const OtpInputWidget({super.key, required this.onCompleted, this.onChanged});

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (index) => TextEditingController());
    _focusNodes = List.generate(4, (index) => FocusNode());

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get otpValue {
    return _controllers.map((controller) => controller.text).join();
  }

  void _onFieldChanged() {
    final otp = otpValue;
    widget.onChanged?.call(otp);

    if (otp.length == 4) {
      // Unfocus all fields
      for (var focusNode in _focusNodes) {
        focusNode.unfocus();
      }
      widget.onCompleted(otp);
    }
  }

  void _onLastFieldCompleted() {
    final otp = otpValue;
    if (otp.length == 4) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive field size based on available width
        final availableWidth = constraints.maxWidth;
        final fieldWidth =
            (availableWidth - (3 * 20.84.w)) /
            4; // 4 fields with spacing from Figma
        final fieldHeight =
            (fieldWidth * 67.16) / 72.4; // Maintain aspect ratio from Figma

        return SizedBox(
          width: availableWidth,
          height: fieldHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              return SizedBox(
                width: fieldWidth,
                height: fieldHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.79.r),
                    border: Border.all(
                      color: const Color(0xFFCADDE1),
                      width: 1.05,
                    ),
                  ),
                  child: Center(
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w600,
                        fontSize: (fieldWidth * 0.33).clamp(16, 24),
                        color: AppColors.black,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index == 3) {
                            _onLastFieldCompleted();
                          } else {
                            // Move to next field
                            FocusScope.of(context).nextFocus();
                          }
                        } else {
                          // Move to previous field if backspace on empty field
                          FocusScope.of(context).previousFocus();
                        }
                        _onFieldChanged();
                      },
                      onTap: () {
                        // Clear the field when tapped
                        _controllers[index].clear();
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
