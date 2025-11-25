import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../api/companies_api.dart';
import '../di/service_locator.dart';
import '../../features/orders/data/models/company_model.dart';

/// Enhanced company field with smart input logic based on available companies
class EnhancedCompanyField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController? positionController;
  final FormFieldValidator<String>? validator;
  final String? selectedCompanyId;
  final ValueChanged<String?>? onCompanyIdChanged;
  final bool enabled;

  const EnhancedCompanyField({
    super.key,
    required this.controller,
    this.positionController,
    this.validator,
    this.selectedCompanyId,
    this.onCompanyIdChanged,
    this.enabled = true,
  });

  @override
  State<EnhancedCompanyField> createState() => _EnhancedCompanyFieldState();
}

class _EnhancedCompanyFieldState extends State<EnhancedCompanyField> {
  late final CompaniesApi _companiesApi;
  final List<CompanyModel> _companies = [];
  bool _isLoading = false;
  bool _isSettingText = false;
  String? _currentCompanyId;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _companiesApi = sl<CompaniesApi>();
    _currentCompanyId = widget.selectedCompanyId;
    widget.controller.addListener(_handleControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCompanies();
    });
  }

  Future<void> _fetchCompanies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _companiesApi.getMyCompanies();
      final companies =
          response
              .map(CompanyModel.fromJson)
              .where((company) => (company.companyName ?? '').trim().isNotEmpty)
              .toList()
            ..sort(
              (a, b) => (a.companyName ?? '').toLowerCase().compareTo(
                (b.companyName ?? '').toLowerCase(),
              ),
            );

      if (!mounted) return;

      setState(() {
        _companies
          ..clear()
          ..addAll(companies);
        _isLoading = false;
      });

      final presetCompany = _findCompanyById(widget.selectedCompanyId);
      if (presetCompany != null) {
        _applyCompany(presetCompany, notify: false, fillPosition: true);
        return;
      }

      if (_companies.length == 1 && widget.controller.text.trim().isEmpty) {
        _applyCompany(_companies.first, notify: true, fillPosition: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить компании: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _handleControllerChanged() {
    if (_isSettingText) {
      _isSettingText = false;
      return;
    }
    if (_currentCompanyId != null) {
      _currentCompanyId = null;
      widget.onCompanyIdChanged?.call(null);
      setState(() {});
    }
  }

  void _applyCompany(
    CompanyModel company, {
    required bool notify,
    bool fillPosition = false,
  }) {
    final title = company.companyName ?? '';
    _isSettingText = true;
    widget.controller
      ..text = title
      ..selection = TextSelection.collapsed(offset: title.length);
    if (fillPosition && widget.positionController != null) {
      final position = company.clientPosition;
      if ((widget.positionController!.text).trim().isEmpty &&
          position != null &&
          position.isNotEmpty) {
        widget.positionController!
          ..text = position
          ..selection = TextSelection.collapsed(offset: position.length);
      }
    }
    if (_currentCompanyId != company.companyId) {
      setState(() {
        _currentCompanyId = company.companyId;
      });
    }
    if (notify) {
      widget.onCompanyIdChanged?.call(company.companyId);
    }
  }

  void _showCompanyDropdown() {
    if (_companies.length < 2 || !widget.enabled) {
      return;
    }

    _removeDropdown();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeDropdown,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, renderBox.size.height + 8.h),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 354.w,
                      constraints: BoxConstraints(maxHeight: 240.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: Offset(0, 8.h),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 16.w,
                        ),
                        shrinkWrap: true,
                        itemCount: _companies.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 8.h,
                          color: AppColors.inputBorderColor,
                        ),
                        itemBuilder: (context, index) {
                          final company = _companies[index];
                          final isSelected =
                              company.companyId != null &&
                              company.companyId == _currentCompanyId;
                          return InkWell(
                            onTap: () {
                              _applyCompany(
                                company,
                                notify: true,
                                fillPosition: true,
                              );
                              _removeDropdown();
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 10.h,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          company.companyName ?? '',
                                          style: AppTextStyles.inputLabel
                                              .copyWith(
                                                color: AppColors.primaryText,
                                                fontWeight: isSelected
                                                    ? FontWeight.w500
                                                    : null,
                                              ),
                                        ),
                                        if ((company.clientPosition ?? '')
                                            .isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4.h),
                                            child: Text(
                                              company.clientPosition!,
                                              style: AppTextStyles.inputLabel
                                                  .copyWith(
                                                    color:
                                                        AppColors.secondaryText,
                                                    fontSize:
                                                        AppTextStyles
                                                                .inputLabel
                                                                .fontSize !=
                                                            null
                                                        ? AppTextStyles
                                                                  .inputLabel
                                                                  .fontSize! -
                                                              2
                                                        : null,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      size: 20.w,
                                      color: AppColors.black,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  InputDecoration _inputDecoration() {
    final suffixIcon = _companies.length > 1
        ? IconButton(
            icon: Icon(
              Icons.expand_more,
              size: 24.w,
              color: AppColors.primaryText,
            ),
            onPressed: _showCompanyDropdown,
          )
        : null;

    return InputDecoration(
      hintText: 'Компания',
      hintStyle: AppTextStyles.inputLabel,
      contentPadding: EdgeInsets.fromLTRB(14.w, 8.h, 12.w, 8.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.inputBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.inputBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryText, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.redAccent, width: 1),
      ),
      filled: true,
      fillColor: AppColors.white,
      suffixIcon: suffixIcon,
    );
  }

  @override
  void didUpdateWidget(covariant EnhancedCompanyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCompanyId != oldWidget.selectedCompanyId &&
        widget.selectedCompanyId != _currentCompanyId &&
        widget.selectedCompanyId != null) {
      final match = _findCompanyById(widget.selectedCompanyId);
      if (match != null) {
        _applyCompany(match, notify: false, fillPosition: false);
      }
    }
  }

  CompanyModel? _findCompanyById(String? id) {
    if (id == null) {
      return null;
    }
    for (final company in _companies) {
      if (company.companyId == id) {
        return company;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _removeDropdown();
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: 354.w,
        height: 50.h,
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.inputBorderColor, width: 1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: 354.w,
        height: 50.h,
        child: TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          enabled: widget.enabled,
          decoration: _inputDecoration(),
          style: AppTextStyles.inputLabel.copyWith(
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
