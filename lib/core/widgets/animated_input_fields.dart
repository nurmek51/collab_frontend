import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../animations/animations.dart';

class AnimatedTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;

  const AnimatedTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.defaultCurve,
      ),
    );

    _borderColorAnimation =
        ColorTween(
          begin: AppColors.black.withOpacity(0.2),
          end: AppColors.black,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: AnimationConstants.defaultCurve,
          ),
        );

    _focusNode.addListener(_onFocusChange);
    widget.controller?.addListener(_onTextChange);
    _hasContent = widget.controller?.text.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _controller.forward();
    } else if (!_hasContent) {
      _controller.reverse();
    }
  }

  void _onTextChange() {
    final hasContent = widget.controller?.text.isNotEmpty ?? false;
    if (hasContent != _hasContent) {
      setState(() {
        _hasContent = hasContent;
      });

      if (_hasContent || _isFocused) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null) ...[
                AnimatedDefaultTextStyle(
                  duration: AnimationConstants.fast,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _isFocused
                        ? AppColors.black
                        : AppColors.black.withOpacity(0.7),
                    fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(widget.label!),
                ),
                SizedBox(height: 8.h),
              ],
              AnimatedContainer(
                duration: AnimationConstants.fast,
                curve: AnimationConstants.defaultCurve,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        _borderColorAnimation.value ??
                        AppColors.black.withOpacity(0.2),
                    width: _isFocused ? 2 : 1,
                  ),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  readOnly: widget.readOnly,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  enabled: widget.enabled,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.black.withOpacity(0.5),
                    ),
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.suffixIcon,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedSearchField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const AnimatedSearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  State<AnimatedSearchField> createState() => _AnimatedSearchFieldState();
}

class _AnimatedSearchFieldState extends State<AnimatedSearchField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.defaultCurve,
      ),
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedContainer(
            duration: AnimationConstants.fast,
            curve: AnimationConstants.defaultCurve,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: _isFocused
                    ? AppColors.black
                    : AppColors.black.withOpacity(0.1),
                width: _isFocused ? 2 : 1,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hint ?? 'Search...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.black.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: _isFocused
                      ? AppColors.black
                      : AppColors.black.withOpacity(0.5),
                ),
                suffixIcon: widget.controller?.text.isNotEmpty == true
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.black.withOpacity(0.5),
                        ),
                        onPressed: () {
                          widget.controller?.clear();
                          widget.onClear?.call();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
