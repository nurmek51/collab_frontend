import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/company_option.dart';

/// Styling configuration for [CompanyDropdownField].
class CompanyDropdownStyle {
  final EdgeInsetsGeometry labelPadding;
  final TextStyle labelStyle;
  final TextStyle errorStyle;
  final EdgeInsetsGeometry fieldPadding;
  final BorderRadiusGeometry fieldBorderRadius;
  final BoxBorder? fieldBorder;
  final Color fieldBackgroundColor;
  final Widget? trailingIcon;
  final TextStyle valueStyle;
  final TextStyle placeholderStyle;
  final EdgeInsetsGeometry dropdownPadding;
  final BorderRadiusGeometry dropdownBorderRadius;
  final List<BoxShadow> dropdownShadow;
  final Color dropdownBackgroundColor;
  final TextStyle dropdownItemStyle;
  final TextStyle dropdownSelectedItemStyle;
  final Color dropdownSelectedIconColor;
  final double dropdownItemSpacing;
  final double overlayVerticalOffset;
  final double dropdownMaxHeight;
  final double? dropdownWidth;
  final Offset dropdownOffset;
  final double? fieldHeight;

  const CompanyDropdownStyle({
    this.labelPadding = EdgeInsets.zero,
    required this.labelStyle,
    required this.errorStyle,
    required this.fieldPadding,
    required this.fieldBorderRadius,
    this.fieldBorder,
    this.fieldBackgroundColor = Colors.transparent,
    this.trailingIcon,
    required this.valueStyle,
    required this.placeholderStyle,
    required this.dropdownPadding,
    required this.dropdownBorderRadius,
    required this.dropdownShadow,
    required this.dropdownBackgroundColor,
    required this.dropdownItemStyle,
    required this.dropdownSelectedItemStyle,
    required this.dropdownSelectedIconColor,
    this.dropdownItemSpacing = 12,
    this.overlayVerticalOffset = 8,
    this.dropdownMaxHeight = 320,
    this.dropdownWidth,
    this.dropdownOffset = Offset.zero,
    this.fieldHeight,
  });
}

/// Dropdown field for selecting companies with optional manual input support.
class CompanyDropdownField extends StatefulWidget {
  final String label;
  final List<CompanyOption> options;
  final String? selectedOptionId;
  final ValueChanged<CompanyOption>? onOptionSelected;
  final ValueChanged<String>? onTextChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enableSearch;
  final bool enabled;
  final bool isLoading;
  final FormFieldValidator<String>? validator;
  final CompanyDropdownStyle style;
  final String? placeholder;
  final bool autofocus;

  const CompanyDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.style,
    this.selectedOptionId,
    this.onOptionSelected,
    this.onTextChanged,
    this.controller,
    this.focusNode,
    this.enableSearch = false,
    this.enabled = true,
    this.isLoading = false,
    this.validator,
    this.placeholder,
    this.autofocus = false,
  });

  @override
  State<CompanyDropdownField> createState() => _CompanyDropdownFieldState();
}

class _CompanyDropdownFieldState extends State<CompanyDropdownField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late String? _selectedId = widget.selectedOptionId;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  Size? _fieldSize;
  bool _textChangedProgrammatically = false;

  List<CompanyOption> get _sortedOptions => widget.options;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    if (widget.enableSearch) {
      _controller.addListener(_handleTextChanged);
    }
    _applySelectedId(widget.selectedOptionId, syncText: true);
  }

  @override
  void didUpdateWidget(covariant CompanyDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller &&
        widget.controller != null) {
      if (oldWidget.controller == null && widget.enableSearch) {
        _controller.removeListener(_handleTextChanged);
      }
      _controller = widget.controller!;
      if (widget.enableSearch) {
        _controller.addListener(_handleTextChanged);
      }
    }
    if (widget.focusNode != oldWidget.focusNode && widget.focusNode != null) {
      if (oldWidget.focusNode == null) {
        _focusNode.removeListener(_handleFocusChange);
      }
      _focusNode = widget.focusNode!;
      _focusNode.addListener(_handleFocusChange);
    }
    if (widget.selectedOptionId != oldWidget.selectedOptionId) {
      _applySelectedId(widget.selectedOptionId, syncText: true);
    }
    if (!listEquals(widget.options, oldWidget.options) && widget.enableSearch) {
      _refreshOverlay();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    if (widget.controller == null) {
      _controller.dispose();
    } else if (widget.enableSearch) {
      _controller.removeListener(_handleTextChanged);
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && widget.enabled) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
    setState(() {});
  }

  void _handleTextChanged() {
    if (_textChangedProgrammatically) {
      _textChangedProgrammatically = false;
      return;
    }
    if (_selectedId != null) {
      setState(() {
        _selectedId = null;
      });
    } else {
      setState(() {});
    }
    widget.onTextChanged?.call(_controller.text);
    if (widget.enableSearch && widget.enabled) {
      _refreshOverlay();
    }
  }

  void _applySelectedId(String? id, {bool syncText = false}) {
    _selectedId = id;
    if (syncText && id != null) {
      CompanyOption? match;
      for (final option in _sortedOptions) {
        if (option.id == id) {
          match = option;
          break;
        }
      }
      if (match != null) {
        _textChangedProgrammatically = true;
        _controller.text = match.name;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context, debugRequiredFor: widget);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
  }

  void _refreshOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final filteredOptions = _filteredOptions();
    return OverlayEntry(
      builder: (context) {
        final size = _fieldSize;
        final width = widget.style.dropdownWidth ?? size?.width ?? 0;
        final yOffset =
            (widget.style.fieldHeight ?? size?.height ?? 0) +
            widget.style.overlayVerticalOffset +
            widget.style.dropdownOffset.dy;
        final xOffset = widget.style.dropdownOffset.dx;
        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeOverlay,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(xOffset, yOffset),
                  child: Material(
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.style.dropdownMaxHeight,
                        minWidth: width,
                        maxWidth: width,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: widget.isLoading
                            ? _buildLoadingState(width)
                            : filteredOptions.isEmpty
                            ? _buildEmptyState(width)
                            : _buildOptionsList(filteredOptions, width),
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
  }

  Widget _buildLoadingState(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: _menuDecoration,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: _menuDecoration,
      child: Text(
        'Нет доступных компаний',
        style: widget.style.dropdownItemStyle,
      ),
    );
  }

  Widget _buildOptionsList(List<CompanyOption> options, double width) {
    return Container(
      width: width,
      padding: widget.style.dropdownPadding,
      decoration: _menuDecoration,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (option) => Padding(
                  padding: EdgeInsets.only(
                    bottom: option == options.last
                        ? 0
                        : widget.style.dropdownItemSpacing,
                  ),
                  child: _buildMenuItem(option),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem(CompanyOption option) {
    final isSelected = option.id == _selectedId;
    final style = isSelected
        ? widget.style.dropdownSelectedItemStyle
        : widget.style.dropdownItemStyle;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        _textChangedProgrammatically = true;
        _controller.text = option.name;
        _controller.selection = TextSelection.collapsed(
          offset: option.name.length,
        );
        setState(() {
          _selectedId = option.id;
        });
        widget.onOptionSelected?.call(option);
        _removeOverlay();
        if (!widget.enableSearch) {
          _focusNode.unfocus();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.name, style: style),
                  if (option.subtitle != null && option.subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        option.subtitle!,
                        style: widget.style.dropdownItemStyle.copyWith(
                          color: widget.style.dropdownItemStyle.color
                              ?.withOpacity(0.64),
                          fontSize:
                              widget.style.dropdownItemStyle.fontSize != null
                              ? widget.style.dropdownItemStyle.fontSize! - 1
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
                size: 20,
                color: widget.style.dropdownSelectedIconColor,
              ),
          ],
        ),
      ),
    );
  }

  List<CompanyOption> _filteredOptions() {
    if (!widget.enableSearch) {
      return _sortedOptions;
    }
    final query = _controller.text;
    if (query.trim().isEmpty) {
      return _sortedOptions;
    }
    return _sortedOptions
        .where((option) => option.matchesQuery(query))
        .toList(growable: false);
  }

  BoxDecoration get _fieldDecoration => BoxDecoration(
    color: widget.style.fieldBackgroundColor,
    borderRadius: widget.style.fieldBorderRadius,
    border: widget.style.fieldBorder,
  );

  BoxDecoration get _menuDecoration => BoxDecoration(
    color: widget.style.dropdownBackgroundColor,
    borderRadius: widget.style.dropdownBorderRadius,
    boxShadow: widget.style.dropdownShadow,
  );

  void _updateFieldSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox) {
        final newSize = renderObject.size;
        if (_fieldSize == null ||
            (_fieldSize!.width - newSize.width).abs() > 0.5 ||
            (_fieldSize!.height - newSize.height).abs() > 0.5) {
          setState(() {
            _fieldSize = newSize;
          });
          _refreshOverlay();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateFieldSize();
    final placeholder = widget.placeholder ?? widget.label;
    return FormField<String>(
      validator: widget.validator,
      initialValue: _controller.text,
      builder: (field) {
        final hasError = field.errorText != null;
        return CompositedTransformTarget(
          link: _layerLink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label.isNotEmpty)
                Padding(
                  padding: widget.style.labelPadding,
                  child: Text(widget.label, style: widget.style.labelStyle),
                ),
              Container(
                height: widget.style.fieldHeight,
                decoration: _fieldDecoration.copyWith(
                  border: hasError
                      ? Border.all(color: Colors.redAccent, width: 1)
                      : widget.style.fieldBorder,
                ),
                padding: widget.style.fieldPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: widget.autofocus,
                        readOnly: !widget.enableSearch,
                        enabled: widget.enabled,
                        style: widget.style.valueStyle,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: placeholder,
                          hintStyle: widget.style.placeholderStyle,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () {
                          if (!widget.enableSearch && widget.enabled) {
                            _focusNode.requestFocus();
                            _showOverlay();
                          }
                        },
                        onChanged: (value) {
                          field.didChange(value);
                          if (!widget.enableSearch) {
                            widget.onTextChanged?.call(value);
                          }
                        },
                      ),
                    ),
                    if (widget.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (widget.style.trailingIcon != null)
                      widget.style.trailingIcon!,
                  ],
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(field.errorText!, style: widget.style.errorStyle),
                ),
            ],
          ),
        );
      },
    );
  }
}
