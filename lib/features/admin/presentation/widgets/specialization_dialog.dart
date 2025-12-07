import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../data/models/admin_order_model.dart';

class AddOrderSpecializationModal extends StatefulWidget {
  final AdminOrderSpecializationModel? initialSpecialization;
  final Future<void> Function(Map<String, dynamic> payload) onSubmit;
  final VoidCallback onCancel;
  final bool isEditing;

  const AddOrderSpecializationModal({
    super.key,
    this.initialSpecialization,
    required this.onSubmit,
    required this.onCancel,
    this.isEditing = false,
  });

  @override
  State<AddOrderSpecializationModal> createState() =>
      _AddOrderSpecializationModalState();
}

class _AddOrderSpecializationModalState
    extends State<AddOrderSpecializationModal> {
  final _formKey = GlobalKey<FormState>();
  late _SpecializationFormEntry _entry;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _entry = widget.initialSpecialization != null
        ? _SpecializationFormEntry.fromModel(widget.initialSpecialization!)
        : _SpecializationFormEntry.blank();
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    final payload = _entry.toPayload();

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSubmit(payload);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCancel() {
    if (_isSaving) return;
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 440,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              bottomLeft: Radius.circular(40),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSaving ? null : _handleCancel,
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Участник',
                        style:
                            theme.textTheme.titleMedium?.copyWith(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              color: AppColors.adminPrimaryText,
                            ) ??
                            const TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              color: AppColors.adminPrimaryText,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ScrollConfiguration(
                        behavior: const _NoGlowBehavior(),
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            Center(
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(53, 63, 73, 0.12),
                                      blurRadius: 24,
                                      offset: Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.adminPrimaryText,
                                  size: 44,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _SpecializationFormCard(
                              index: 0,
                              entry: _entry,
                              isSaving: _isSaving,
                              onRemove: null, // No remove for single entry
                              onSkillLevelChanged: (value) {
                                setState(() {
                                  _entry.skillLevel = value;
                                });
                              },
                              onPayPerChanged: (value) {
                                setState(() {
                                  _entry.payPer = value;
                                });
                              },
                              onScheduleTypeChanged: (value) {
                                setState(() {
                                  _entry.scheduleType = value;
                                });
                              },
                              onFormatTypeChanged: (value) {
                                setState(() {
                                  _entry.formatType = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : _handleCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.adminPrimaryText,
                              side: const BorderSide(color: Colors.white54),
                              backgroundColor: Colors.white.withOpacity(0.35),
                              textStyle: const TextStyle(
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            child: const Text('Отменить'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Сохранить'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecializationFormCard extends StatelessWidget {
  final int index;
  final _SpecializationFormEntry entry;
  final bool isSaving;
  final VoidCallback? onRemove;
  final ValueChanged<String> onSkillLevelChanged;
  final ValueChanged<String> onPayPerChanged;
  final ValueChanged<String> onScheduleTypeChanged;
  final ValueChanged<String> onFormatTypeChanged;

  const _SpecializationFormCard({
    required this.index,
    required this.entry,
    required this.isSaving,
    this.onRemove,
    required this.onSkillLevelChanged,
    required this.onPayPerChanged,
    required this.onScheduleTypeChanged,
    required this.onFormatTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Вакансия ${index + 1}',
            style: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppColors.adminPrimaryText,
            ),
          ),
          const SizedBox(height: 20),
          _LabeledTextDropdownField(
            label: 'Специализация',
            controller: entry.specializationController,
            hintText: 'Введите специализацию',
            options: SpecializationConstants.availableSpecializations,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Заполните поле';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _LabeledDropdownField(
            label: 'Уровень',
            value: entry.skillLevel,
            options: _skillLevelOptions,
            onChanged: isSaving
                ? null
                : (value) {
                    if (value != null) {
                      onSkillLevelChanged(value);
                    }
                  },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LabeledTextFormField(
                  label: 'Оплата',
                  controller: entry.salaryController,
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  suffixText: '₸',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledDropdownField(
                  label: 'Тип оплаты',
                  value: entry.payPer,
                  options: _payPerOptions,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            onPayPerChanged(value);
                          }
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LabeledTextFormField(
                  label: 'Опыт (в годах)',
                  controller: entry.experienceController,
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  suffixText: 'лет',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledDropdownField(
                  label: 'Тип занятости',
                  value: entry.scheduleType,
                  options: _scheduleTypeOptions,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            onScheduleTypeChanged(value);
                          }
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LabeledDropdownField(
            label: 'Формат работы',
            value: entry.formatType,
            options: _formatTypeOptions,
            onChanged: isSaving
                ? null
                : (value) {
                    if (value != null) {
                      onFormatTypeChanged(value);
                    }
                  },
          ),
          const SizedBox(height: 16),
          _LabeledTextFormField(
            label: 'Дополнительные требования',
            controller: entry.requirementsController,
            hintText: 'Опишите пожелания к специалисту',
            maxLines: 4,
          ),
          if (onRemove != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: isSaving ? null : onRemove,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE44848),
                textStyle: const TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              child: const Text('Удалить из проекта'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecializationFormEntry {
  final TextEditingController specializationController;
  final TextEditingController salaryController;
  final TextEditingController experienceController;
  final TextEditingController requirementsController;
  String skillLevel;
  String payPer;
  String scheduleType;
  String formatType;

  _SpecializationFormEntry({
    required String specialization,
    required String requirements,
    required String skillLevel,
    required num? salary,
    required String payPer,
    required num? experience,
    required String scheduleType,
    required String formatType,
  }) : specializationController = TextEditingController(text: specialization),
       salaryController = TextEditingController(
         text: salary != null && salary > 0 ? salary.toString() : '',
       ),
       experienceController = TextEditingController(
         text: experience != null && experience > 0
             ? experience.toString()
             : '',
       ),
       requirementsController = TextEditingController(text: requirements),
       skillLevel = skillLevel,
       payPer = payPer,
       scheduleType = scheduleType,
       formatType = formatType;

  factory _SpecializationFormEntry.fromModel(
    AdminOrderSpecializationModel model,
  ) {
    final conditions = model.conditions;
    final salary = conditions?.salary;
    final experience = conditions?.requiredExperience;

    String resolve(List<_FieldOption> options, String? value) {
      if (value == null) return options.first.value;
      final normalized = value.toLowerCase();
      return options.any((option) => option.value == normalized)
          ? normalized
          : options.first.value;
    }

    return _SpecializationFormEntry(
      specialization: SpecializationConstants.getDisplayNameFromKey(
        model.specialization ?? '',
      ),
      requirements: model.requirements ?? '',
      skillLevel: resolve(_skillLevelOptions, model.skillLevel?.toLowerCase()),
      salary: salary,
      payPer: resolve(_payPerOptions, conditions?.payPer?.toLowerCase()),
      experience: experience,
      scheduleType: resolve(
        _scheduleTypeOptions,
        conditions?.scheduleType?.toLowerCase(),
      ),
      formatType: resolve(
        _formatTypeOptions,
        conditions?.formatType?.toLowerCase(),
      ),
    );
  }

  factory _SpecializationFormEntry.blank() {
    return _SpecializationFormEntry(
      specialization: '',
      requirements: '',
      skillLevel: _skillLevelOptions.first.value,
      salary: null,
      payPer: _payPerOptions.first.value,
      experience: null,
      scheduleType: _scheduleTypeOptions.first.value,
      formatType: _formatTypeOptions.first.value,
    );
  }

  Map<String, dynamic> toPayload() {
    final salary = int.tryParse(salaryController.text.trim());
    final experience = int.tryParse(experienceController.text.trim());

    return {
      'specialization': SpecializationConstants.getKeyFromDisplayName(
        specializationController.text.trim(),
      ),
      'skill_level': skillLevel,
      'requirements': requirementsController.text.trim(),
      'conditions': {
        'salary': salary ?? 0,
        'pay_per': payPer,
        'required_experience': experience ?? 0,
        'schedule_type': scheduleType,
        'format_type': formatType,
      },
    };
  }

  void dispose() {
    specializationController.dispose();
    salaryController.dispose();
    experienceController.dispose();
    requirementsController.dispose();
  }
}

class _LabeledTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? suffixText;
  final String? Function(String?)? validator;

  const _LabeledTextFormField({
    required this.label,
    required this.controller,
    this.hintText = '',
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.suffixText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(53, 63, 73, 0.08),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.adminSecondaryText,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: AppColors.adminPrimaryText,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Color.fromRGBO(0, 0, 0, 0.35),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 4),
              suffixText: suffixText,
              suffixStyle: const TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.adminSecondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<_FieldOption> options;
  final ValueChanged<String?>? onChanged;

  const _LabeledDropdownField({
    required this.label,
    required this.value,
    required this.options,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedValue = options.any((option) => option.value == value)
        ? value
        : options.first.value;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(53, 63, 73, 0.08),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.adminSecondaryText,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: resolvedValue,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.adminPrimaryText,
              ),
              onChanged: onChanged,
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.value,
                      child: Text(
                        option.label,
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: AppColors.adminPrimaryText,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledTextDropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final List<Map<String, String>> options;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const _LabeledTextDropdownField({
    required this.label,
    required this.controller,
    this.hintText = '',
    required this.options,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(53, 63, 73, 0.08),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.adminSecondaryText,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: AppColors.adminPrimaryText,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Color.fromRGBO(0, 0, 0, 0.35),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 4),
                  ),
                  onChanged: onChanged,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.adminPrimaryText,
                ),
                onPressed: () {
                  final RenderBox button =
                      context.findRenderObject() as RenderBox;
                  final Offset buttonPosition = button.localToGlobal(
                    Offset.zero,
                  );
                  final Size buttonSize = button.size;
                  final OverlayState overlayState = Overlay.of(context);
                  late final OverlayEntry overlayEntry;
                  overlayEntry = OverlayEntry(
                    builder: (context) => Positioned(
                      left: buttonPosition.dx,
                      top: buttonPosition.dy + buttonSize.height,
                      width: buttonSize.width,
                      child: Material(
                        elevation: 4,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView(
                            shrinkWrap: true,
                            children: options
                                .where((option) => option['key'] != 'other')
                                .map((option) {
                                  return ListTile(
                                    title: Text(option['title']!),
                                    onTap: () {
                                      controller.text = option['title']!;
                                      onChanged?.call(option['title']!);
                                      overlayEntry.remove();
                                    },
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                  overlayState.insert(overlayEntry);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldOption {
  final String value;
  final String label;

  const _FieldOption(this.value, this.label);
}

const List<_FieldOption> _skillLevelOptions = [
  _FieldOption('junior', 'Junior'),
  _FieldOption('middle', 'Middle'),
  _FieldOption('senior', 'Senior'),
];

const List<_FieldOption> _payPerOptions = [
  _FieldOption('month', 'В месяц'),
  _FieldOption('hours', 'В час'),
  _FieldOption('words', 'За слово'),
];

const List<_FieldOption> _scheduleTypeOptions = [
  _FieldOption('full-time', 'Полная занятость'),
  _FieldOption('part-time', 'Частичная занятость'),
];

const List<_FieldOption> _formatTypeOptions = [
  _FieldOption('remote', 'Удалённо'),
  _FieldOption('hybrid', 'Гибрид'),
  _FieldOption('onsite', 'В офисе'),
];

class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
