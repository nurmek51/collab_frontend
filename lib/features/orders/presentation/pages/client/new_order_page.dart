import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../auth/presentation/widgets/gradient_background.dart';
import '../../../data/repositories/orders_repository_impl.dart';
import '../../../domain/usecases/create_order.dart';
import '../../../domain/entities/order.dart';
import '../../widgets/custom_input_field.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../../shared/utils/help_utils.dart';
import '../../../../../shared/widgets/enhanced_company_field.dart';
import '../../../../../shared/services/callback_button_manager.dart';
import '../../../../../shared/state/orders_state_manager.dart';
import '../../../../../shared/utils/field_controller.dart';

/// New Order form page for creating client orders
class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final _formKey = GlobalKey<FormState>();
  late final FieldController _clientNameField;
  late final FieldController _positionField;
  late final FieldController _companyNameField;
  late final FieldController _descriptionField;

  bool _isLoading = false;
  bool _isLoadingProfile = true;
  bool _isNameEditable = false;
  String? _selectedCompanyId;
  late final CreateOrder _createOrderUseCase;
  late final ApiService _apiService;
  late final OrdersStateManager _ordersStateManager;
  late final CallbackButtonManager _callbackButtonManager;

  @override
  void initState() {
    super.initState();
    // Initialize field controllers
    _clientNameField = FieldController();
    _positionField = FieldController();
    _companyNameField = FieldController();
    _descriptionField = FieldController();

    // Initialize use case with dependencies
    _apiService = sl<ApiService>();
    final repository = OrdersRepositoryImpl(_apiService);
    _createOrderUseCase = CreateOrder(repository);
    _ordersStateManager = sl<OrdersStateManager>();
    _callbackButtonManager = CallbackButtonManager.getInstance('new_order');

    // Fetch user profile to pre-fill name fields
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _clientNameField.dispose();
    _positionField.dispose();
    _companyNameField.dispose();
    _descriptionField.dispose();
    CallbackButtonManager.disposeInstance('new_order');
    super.dispose();
  }

  Future<void> _requestCallback() async {
    await _callbackButtonManager.requestCallback(
      onSuccess: () {
        if (mounted) {
          // Add callback order to state so my_orders_page updates immediately
          final callbackOrder = Order(
            id: 'callback_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Admin Help Request',
            description: 'Request for callback',
            status: 'pending',
            createdAt: DateTime.now(),
          );
          _ordersStateManager.addOrderOptimistically(callbackOrder);

          context.push('/callback-accepted');
        }
      },
      onError: (errorMessage) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      },
    );
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) {
      // Focus first invalid field
      final firstErrorWidget = _getFirstErrorWidget();
      firstErrorWidget?.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Generate optimistic order
    final optimisticOrder = Order(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      title: _descriptionField.text.trim(),
      description: _descriptionField.text.trim(),
      status: 'pending',
      createdAt: DateTime.now(),
      companyId: _selectedCompanyId,
    );

    // Add optimistically to orders list
    _ordersStateManager.addOrderOptimistically(optimisticOrder);

    try {
      final contactText = _clientNameField.text.trim();
      final parts = contactText.split(' ');
      final firstName = parts.isNotEmpty ? parts[0] : null;
      final lastName = parts.length > 1 ? parts[1] : null;

      final createdOrder = await _createOrderUseCase(
        companyName: _companyNameField.text.trim(),
        companyPosition: _positionField.text.trim(),
        orderDescription: _descriptionField.text.trim(),
        firstName: firstName,
        lastName: lastName,
        title: _descriptionField.text.trim(),
        specializations: [],
      );

      if (mounted) {
        // Remove optimistic order and add real order
        _ordersStateManager.removeOrderOptimistically(optimisticOrder.id);
        _ordersStateManager.addOrderOptimistically(createdOrder);

        // Show success and navigate back
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Заказ успешно создан!'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        // Remove optimistic order on failure
        _ordersStateManager.removeOrderOptimistically(optimisticOrder.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания заказа: $e'),
            backgroundColor: Colors.red,
          ),
        );

        // Focus first invalid field if validation error
        final firstErrorWidget = _getFirstErrorWidget();
        firstErrorWidget?.requestFocus();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  FocusNode? _getFirstErrorWidget() {
    if (_companyNameField.text.trim().isEmpty) {
      return null; // Company field has its own focus handling
    }
    if (_positionField.text.trim().isEmpty) {
      return _positionField.focusNode;
    }
    if (_descriptionField.text.trim().isEmpty) {
      return _descriptionField.focusNode;
    }
    return null;
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Это поле обязательно для заполнения';
    }
    return null;
  }

  String? _validateCompanyName(String? value) {
    return _validateRequired(value);
  }

  String? _validateCompanyPosition(String? value) {
    return _validateRequired(value);
  }

  String? _validateOrderDescription(String? value) {
    return _validateRequired(value);
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();

      if (mounted) {
        // Safely access the nested data structure from API response
        final data = response['data'];
        final profile = data is Map<String, dynamic> ? data : null;

        if (profile != null) {
          // Safely extract name and surname values
          final name = profile['name']?.toString();
          final surname = profile['surname']?.toString();

          setState(() {
            // Pre-fill name field if available
            if (name != null &&
                name.isNotEmpty &&
                surname != null &&
                surname.isNotEmpty) {
              _clientNameField.text = '$name $surname';
              _isNameEditable = false; // Keep read-only if we have data
            } else {
              _isNameEditable = true; // Make editable if no data
            }

            _isLoadingProfile = false;
          });
        } else {
          // No profile data, make field editable
          setState(() {
            _isNameEditable = true;
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // On error, make field editable so user can still create order
          _isNameEditable = true;
          _isLoadingProfile = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить профиль: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),

                    // Back button
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 61.w,
                          height: 31.h,
                          alignment: Alignment.centerLeft,
                          child: SvgPicture.asset(
                            'assets/svgs/back_arrow.svg',
                            width: 26.w,
                            height: 26.w,
                            colorFilter: ColorFilter.mode(
                              AppColors.primaryText,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h), // 112 - 69 = 43
                    // Page title
                    Padding(
                      padding: EdgeInsets.only(left: 24.w),
                      child: Text(
                        'Новый заказ',
                        style: AppTextStyles.pageTitle,
                      ),
                    ),

                    SizedBox(height: 28.h), // 176 - 112 = 64
                    // Form fields
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          // Client Name
                          _isLoadingProfile
                              ? Container(
                                  width: 354.w,
                                  height: 50.h,
                                  padding: EdgeInsets.fromLTRB(
                                    14.w,
                                    8.h,
                                    14.w,
                                    10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    border: Border.all(
                                      color: AppColors.inputBorderColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                )
                              : CustomInputField(
                                  label: 'Контактное лицо',
                                  controller: _clientNameField.textController,
                                  focusNode: _clientNameField.focusNode,
                                  validator: null, // Name is optional now
                                  readOnly: !_isNameEditable,
                                  enabled: !_isLoading,
                                ),
                          SizedBox(height: 10.h),

                          // // Position
                          // CustomInputField(
                          //   label: 'Ваша должность',
                          //   controller: _positionField.textController,
                          //   focusNode: _positionField.focusNode,
                          //   validator: _validateCompanyPosition,
                          //   enabled: !_isLoading,
                          // ),
                          // SizedBox(height: 10.h),

                          // Company Name
                          EnhancedCompanyField(
                            controller: _companyNameField.textController,
                            positionController: _positionField.textController,
                            validator: _validateCompanyName,
                            selectedCompanyId: _selectedCompanyId,
                            onCompanyIdChanged: (companyId) {
                              setState(() {
                                _selectedCompanyId = companyId;
                              });
                            },
                            enabled: !_isLoading,
                          ),
                          SizedBox(height: 10.h),

                          // Task description (textarea)
                          CustomInputField(
                            label: AppLocalizations.of(
                              context,
                            )!.orders_new_description_hint,
                            controller: _descriptionField.textController,
                            focusNode: _descriptionField.focusNode,
                            validator: _validateOrderDescription,
                            isTextArea: true,
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            enabled: !_isLoading,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 54.h), // 649 - 500 = 149 (approximate)
                    // Create Order button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SizedBox(
                        width: 354.w,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.black,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Создать заказ',
                                  style: AppTextStyles.buttonText,
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h), // 741 - 649 = 92
                    Center(
                      child: Column(
                        children: [
                          ListenableBuilder(
                            listenable: _callbackButtonManager,
                            builder: (context, child) {
                              return GestureDetector(
                                onTap: _callbackButtonManager.isPending
                                    ? null
                                    : _requestCallback,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_callbackButtonManager.isPending) ...[
                                        SizedBox(
                                          width: 16.w,
                                          height: 16.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.linkColor,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                      ],
                                      Text(
                                        _callbackButtonManager.isPending
                                            ? 'Отправляем запрос...'
                                            : 'Заказать обратный звонок',
                                        style: AppTextStyles.linkText.copyWith(
                                          color:
                                              _callbackButtonManager.isPending
                                              ? AppColors.secondaryText
                                              : AppColors.linkColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16.h),
                          GestureDetector(
                            onTap: () async {
                              await HelpUtils.showSocialLinksModal(context);
                            },
                            child: Text(
                              'Связаться с Collab',
                              style: AppTextStyles.linkText,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 47.h), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
