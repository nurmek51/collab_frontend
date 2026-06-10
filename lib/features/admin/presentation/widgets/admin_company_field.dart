import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_company_model.dart';

/// Company name field for admin order pages.
/// Mirrors [EnhancedCompanyField] overlay/input behaviour.
class AdminCompanyField extends StatefulWidget {
  final TextEditingController controller;
  final List<AdminCompanyModel> companies;
  final bool isLoading;
  final String? selectedCompanyId;
  final ValueChanged<AdminCompanyModel>? onCompanySelected;
  final VoidCallback? onFocusLost;
  final bool enabled;
  final String hintText;

  const AdminCompanyField({
    super.key,
    required this.controller,
    required this.companies,
    this.isLoading = false,
    this.selectedCompanyId,
    this.onCompanySelected,
    this.onFocusLost,
    this.enabled = true,
    this.hintText = 'Компания',
  });

  @override
  State<AdminCompanyField> createState() => AdminCompanyFieldState();
}

class AdminCompanyFieldState extends State<AdminCompanyField> {
  bool _isSettingText = false;
  String? _currentCompanyId;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late final FocusNode _focusNode;

  List<AdminCompanyModel> get _sortedCompanies {
    final items = widget.companies
        .where((company) => (company.companyName ?? '').trim().isNotEmpty)
        .toList(growable: false);
    items.sort(
      (a, b) => (a.companyName ?? '').toLowerCase().compareTo(
        (b.companyName ?? '').toLowerCase(),
      ),
    );
    return items;
  }

  @override
  void initState() {
    super.initState();
    _currentCompanyId = widget.selectedCompanyId;
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant AdminCompanyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCompanyId != oldWidget.selectedCompanyId &&
        widget.selectedCompanyId != _currentCompanyId) {
      _currentCompanyId = widget.selectedCompanyId;
      final match = _findCompanyById(widget.selectedCompanyId);
      if (match != null) {
        _applyCompany(match, notify: false);
      }
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onFocusLost?.call();
    }
  }

  void _handleControllerChanged() {
    if (_isSettingText) {
      _isSettingText = false;
      return;
    }
    if (_currentCompanyId != null) {
      _currentCompanyId = null;
      setState(() {});
    }
  }

  void setTextSilently(String text) {
    if (widget.controller.text == text) {
      return;
    }
    _isSettingText = true;
    widget.controller
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
  }

  void _applyCompany(AdminCompanyModel company, {required bool notify}) {
    final title = company.companyName ?? '';
    _isSettingText = true;
    widget.controller
      ..text = title
      ..selection = TextSelection.collapsed(offset: title.length);
    if (_currentCompanyId != company.companyId) {
      setState(() {
        _currentCompanyId = company.companyId;
      });
    }
    if (notify) {
      widget.onCompanySelected?.call(company);
    }
  }

  AdminCompanyModel? _findCompanyById(String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }
    for (final company in _sortedCompanies) {
      if (company.companyId == id) {
        return company;
      }
    }
    return null;
  }

  void _showCompanyDropdown() {
    if (_sortedCompanies.length < 2 || !widget.enabled) {
      return;
    }

    _removeDropdown();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final fieldWidth = renderBox.size.width;

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
                  offset: Offset(0, renderBox.size.height + 8),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: fieldWidth,
                      constraints: const BoxConstraints(maxHeight: 360),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 25,
                            offset: Offset.zero,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
                        shrinkWrap: true,
                        itemCount: _sortedCompanies.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final company = _sortedCompanies[index];
                          final isSelected =
                              company.companyId.isNotEmpty &&
                              company.companyId == _currentCompanyId;
                          return InkWell(
                            onTap: () {
                              _applyCompany(company, notify: true);
                              _removeDropdown();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
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
                                          style: TextStyle(
                                            fontFamily: 'Ubuntu',
                                            fontWeight: isSelected
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                            fontSize: 17,
                                            color: isSelected
                                                ? const Color(0xFF2782E3)
                                                : const Color(0xFF353F49),
                                          ),
                                        ),
                                        if ((company.clientPosition ?? '')
                                            .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              company.clientPosition!,
                                              style: TextStyle(
                                                fontFamily: 'Ubuntu',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: const Color(0xFF353F49)
                                                    .withValues(alpha: 0.64),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check,
                                      size: 20,
                                      color: Color(0xFF2782E3),
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
    final suffixIcon = _sortedCompanies.length > 1
        ? IconButton(
            icon: const Icon(
              Icons.expand_more,
              size: 20,
              color: Color(0xFF2782E3),
            ),
            onPressed: _showCompanyDropdown,
          )
        : null;

    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        fontSize: 28,
        color: AppColors.adminSecondaryText.withValues(alpha: 0.7),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCADDE1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCADDE1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2782E3)),
      ),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
    );
  }

  @override
  void dispose() {
    _removeDropdown();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && _sortedCompanies.isEmpty) {
      return Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCADDE1)),
        ),
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        maxLines: 1,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w700,
          fontSize: 28,
          color: AppColors.adminPrimaryText,
        ),
        decoration: _inputDecoration(),
      ),
    );
  }
}
