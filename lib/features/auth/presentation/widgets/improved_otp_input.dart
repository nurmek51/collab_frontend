import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

/// Improved OTP input widget with paste support and proper navigation
class ImprovedOtpInput extends StatefulWidget {
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final bool isVerifying;
  final int length;

  const ImprovedOtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.isVerifying = false,
    this.length = 4,
  });

  @override
  State<ImprovedOtpInput> createState() => _ImprovedOtpInputState();
}

class _ImprovedOtpInputState extends State<ImprovedOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _values;
  bool _isPasting = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _values = List.filled(widget.length, '');

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });

    // Add listeners to controllers
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() => _onControllerChanged(i));
    }
  }

  @override
  void didUpdateWidget(ImprovedOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No special logic needed anymore - OTP page handles submission control
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

  void _onControllerChanged(int index) {
    // Ignore changes during paste operations
    if (_isPasting) return;

    final value = _controllers[index].text;

    if (value.length > 1) {
      // Handle pasted content - distribute digits across fields
      _handlePaste(value, index);
      return;
    }

    _values[index] = value;
    _notifyChange();

    if (value.isNotEmpty && index < widget.length - 1) {
      // Move to next field
      _setFocus(index + 1);
    } else if (value.isNotEmpty && index == widget.length - 1) {
      // Last field filled, remove focus
      _focusNodes[index].unfocus();
    }

    // Auto-submit when all fields are filled
    if (_values.every((v) => v.isNotEmpty)) {
      _submitOtp();
    }
  }

  void _handlePaste(String pastedText, int startIndex) {
    // Extract digits from pasted text
    final digits = pastedText.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return;

    // Set pasting flag to prevent recursive calls
    _isPasting = true;

    // Clear all fields first
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].clear();
      _values[i] = '';
    }

    // Fill fields with digits starting from the first field
    final maxDigits = digits.length.clamp(0, widget.length);
    for (int i = 0; i < maxDigits; i++) {
      _values[i] = digits[i];
      _controllers[i].text = digits[i];
    }

    // Clear pasting flag
    _isPasting = false;

    // Set focus to the next empty field or last field if all filled
    if (maxDigits < widget.length) {
      _setFocus(maxDigits);
    } else {
      _focusNodes[widget.length - 1].unfocus();
    }

    _notifyChange();

    // Auto-submit if we have enough digits
    if (maxDigits >= widget.length) {
      _submitOtp();
    }
  }

  void _setFocus(int index) {
    if (index >= 0 && index < widget.length) {
      _focusNodes[index].requestFocus();
    }
  }

  void _notifyChange() {
    final currentValue = _values.join();
    widget.onChanged?.call(currentValue);
  }

  void _submitOtp() {
    final otp = _values.join();
    if (otp.length == widget.length && !widget.isVerifying) {
      widget.onCompleted(otp);
    }
  }

  void _handleKeyDown(KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      // Handle paste shortcuts
      if ((event.logicalKey == LogicalKeyboardKey.keyV &&
              (HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isMetaPressed)) ||
          (event.logicalKey == LogicalKeyboardKey.paste)) {
        _handlePasteShortcut(index);
        return;
      }

      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          // Move to previous field and clear it
          _setFocus(index - 1);
          _controllers[index - 1].clear();
          _values[index - 1] = '';
          _notifyChange();
        }
      }
    }
  }

  Future<void> _handlePasteShortcut(int index) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final pastedText = clipboardData?.text ?? '';

      if (pastedText.isNotEmpty && pastedText.length > 1) {
        _handlePaste(pastedText, index);
      }
    } catch (e) {
      // Ignore clipboard errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive field size
        final availableWidth = constraints.maxWidth;
        final spacing = widget.length > 4 ? 6.w : 20.84.w;
        final fieldWidth =
            (availableWidth - ((widget.length - 1) * spacing)) / widget.length;
        final fieldHeight = (fieldWidth * 70.16) / 70.4;
        final borderRadius = (fieldWidth * 0.22).clamp(10.0, 16.79);

        return SizedBox(
          width: availableWidth,
          height: fieldHeight,
          child: Row(
            children: List.generate(widget.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.length - 1 ? 0 : spacing,
                ),
                child: SizedBox(
                  width: fieldWidth,
                  height: fieldHeight,
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) => _handleKeyDown(event, index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(borderRadius.r),
                        border: Border.all(
                          color: widget.isVerifying
                              ? Colors.grey[400]!
                              : const Color(0xFFCADDE1),
                          width: 1.05,
                        ),
                      ),
                      child: Center(
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          enabled: !widget.isVerifying,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w600,
                            fontSize: (fieldWidth * 0.33).clamp(16, 24),
                            color: widget.isVerifying
                                ? Colors.grey[600]
                                : AppColors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10), // Allow paste
                          ],
                          onTap: () {
                            // Clear the field when tapped if not verifying
                            if (!widget.isVerifying) {
                              _controllers[index].clear();
                              _values[index] = '';
                              _notifyChange();
                            }
                            // During verification, fields are disabled so this won't be called
                          },
                        ),
                      ),
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
