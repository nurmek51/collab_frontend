import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

/// Enhanced specialization checkbox item widget with sliding dropdown for level selection
class SpecializationCheckbox extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final String? selectedLevel;
  final Function(String)? onLevelChanged;
  final List<Map<String, String>>? availableLevels;
  final bool showLevelDropdown;

  const SpecializationCheckbox({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.selectedLevel,
    this.onLevelChanged,
    this.availableLevels,
    this.showLevelDropdown = false,
  });

  @override
  State<SpecializationCheckbox> createState() => _SpecializationCheckboxState();
}

class _SpecializationCheckboxState extends State<SpecializationCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void didUpdateWidget(SpecializationCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showLevelDropdown != oldWidget.showLevelDropdown) {
      if (widget.showLevelDropdown) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDropdown =
        widget.isSelected &&
        widget.showLevelDropdown &&
        widget.availableLevels != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main specialization item
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 70.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: hasDropdown && _heightAnimation.value > 0
                    ? BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                      )
                    : BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  // Custom checkbox
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AppColors.black
                          : AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isSelected
                            ? AppColors.black
                            : const Color(0xFFADC1C5),
                        width: 2.0,
                      ),
                    ),
                    child: widget.isSelected
                        ? Icon(Icons.check, color: AppColors.white, size: 16.sp)
                        : null,
                  ),

                  SizedBox(width: 10.w),

                  // Title text
                  Expanded(
                    child: Text(
                      widget.title,
                      softWrap: true,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        height: 1.3,
                        color: const Color(0xFF353F49),
                      ),
                    ),
                  ),

                  // Dropdown indicator arrow when applicable
                  if (widget.isSelected && widget.availableLevels != null)
                    AnimatedRotation(
                      turns: widget.showLevelDropdown ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: const Color(0xFF353F49),
                        size: 20.sp,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Sliding level dropdown - seamlessly connected
          if (hasDropdown)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: _heightAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16.r),
                            bottomRight: Radius.circular(16.r),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: const Color(0xFFE8F1F3),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Уточни уровень" header - left aligned
                            Padding(
                              padding: EdgeInsets.only(
                                left: 16.w,
                                right: 16.w,
                                top: 16.h,
                                bottom: 8.h,
                              ),
                              child: Text(
                                'Уточни уровень',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                  height: 1.3,
                                  color: const Color(0xFF7A8A8E),
                                ),
                              ),
                            ),

                            // Level options
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                children: widget.availableLevels!.map((level) {
                                  final isLevelSelected =
                                      widget.selectedLevel == level['key'];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: GestureDetector(
                                      onTap: () => widget.onLevelChanged?.call(
                                        level['key']!,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 16.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isLevelSelected
                                              ? const Color(0x1A000000)
                                              : const Color(0x0A000000),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          border: isLevelSelected
                                              ? Border.all(
                                                  color: AppColors.black
                                                      .withValues(alpha: 0.1),
                                                  width: 1.0,
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            // Custom radio button
                                            Container(
                                              width: 20.w,
                                              height: 20.h,
                                              decoration: BoxDecoration(
                                                color: isLevelSelected
                                                    ? AppColors.black
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isLevelSelected
                                                      ? AppColors.black
                                                      : const Color(0xFFADC1C5),
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: isLevelSelected
                                                  ? Center(
                                                      child: Container(
                                                        width: 6.w,
                                                        height: 6.h,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: AppColors
                                                                  .white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                    )
                                                  : null,
                                            ),

                                            SizedBox(width: 12.w),

                                            // Level title
                                            Expanded(
                                              child: Text(
                                                level['title']!,
                                                style: TextStyle(
                                                  fontFamily: 'Ubuntu',
                                                  fontWeight: isLevelSelected
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                  fontSize: 15.sp,
                                                  height: 1.3,
                                                  color: const Color(
                                                    0xFF353F49,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            // Bottom padding
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Custom text field for "Other" specialization input
class CustomSpecializationInput extends StatefulWidget {
  final String? value;
  final Function(String) onChanged;
  final bool isVisible;

  const CustomSpecializationInput({
    super.key,
    this.value,
    required this.onChanged,
    required this.isVisible,
  });

  @override
  State<CustomSpecializationInput> createState() =>
      _CustomSpecializationInputState();
}

class _CustomSpecializationInputState extends State<CustomSpecializationInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(CustomSpecializationInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if the value comes from outside (parent changed it)
    // Don't update if it's just a rebuild from our own onChanged
    if (widget.value != null &&
        widget.value != oldWidget.value &&
        _controller.text != widget.value) {
      _controller.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
            height: 1.5,
            color: const Color(0xFF353F49),
          ),
          decoration: InputDecoration(
            hintText: 'Введите ваш вариант',
            hintStyle: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              height: 1.5,
              color: const Color(0xFFBCC5C7),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
        ),
      ),
    );
  }
}
