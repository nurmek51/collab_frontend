import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/widgets/gradient_background.dart';
import '../../data/models/client_profile_model.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/update_client_profile.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/api/companies_api.dart';
import '../../../../shared/api/auth_api.dart';
import 'package:flutter/services.dart';

/// Client Profile page for editing user profile information
class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // Combined full name controller (Имя и фамилия)
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  // New fields required by the UI (position and company shown in design)
  final _positionController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  late final UpdateClientProfile _updateClientProfileUseCase;
  late final ApiService _apiService;
  // Note: GetClientProfile use case is not required because we call /clients/profile directly

  @override
  void initState() {
    super.initState();
    // Initialize use cases with dependencies
    final apiService = sl<ApiService>();
    final repository = ProfileRepositoryImpl(apiService);
    _updateClientProfileUseCase = UpdateClientProfile(repository);
    _apiService = apiService;
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the dedicated endpoint that returns the current user's client profile
      final response = await _apiService.get('/clients/profile');
      final profile = ClientProfileModel.fromJson(
        response['data'] as Map<String, dynamic>,
      );

      // Fetch last order outside setState to avoid async callback inside setState
      List<dynamic> orders = <dynamic>[];
      try {
        orders = await _api_service_get_my_orders_safe();
      } catch (_) {
        orders = <dynamic>[];
      }

      // Try to fetch company details if the order has company_id
      String companyName = '';
      String clientPosition = '';

      if (orders.isNotEmpty) {
        final lastOrder = orders.first as Map<String, dynamic>;

        // Extract company id from order (try multiple possible keys)
        String? companyId;
        for (final key in ['company_id', 'companyId', 'company']) {
          final val = lastOrder[key];
          if (val is String && val.trim().isNotEmpty) {
            companyId = val.trim();
            break;
          }
          if (val is Map<String, dynamic>) {
            final nestedId = val['company_id'] ?? val['id'] ?? val['companyId'];
            if (nestedId is String && nestedId.trim().isNotEmpty) {
              companyId = nestedId.trim();
              break;
            }
          }
        }

        if (companyId != null && companyId.isNotEmpty) {
          try {
            final companiesApi = sl<CompaniesApi>();
            final companyResponse = await companiesApi.getCompanyById(
              companyId,
            );
            // Handle nullable response
            if (companyResponse != null) {
              // Prefer explicit keys from company API
              final maybeName =
                  companyResponse['company_name'] ?? companyResponse['name'];
              if (maybeName is String && maybeName.trim().isNotEmpty)
                companyName = maybeName.trim();

              final maybePos =
                  companyResponse['client_position'] ??
                  companyResponse['client_position_name'] ??
                  companyResponse['clientPosition'];
              if (maybePos is String && maybePos.trim().isNotEmpty)
                clientPosition = maybePos.trim();
            }
          } catch (e) {
            // ignore and fallback to order fields
            companyName = '';
            clientPosition = '';
          }
        }

        // If company lookup didn't yield values, fallback to reading from the order data
        if (companyName.isEmpty) {
          companyName = _extractOrderField(lastOrder, [
            'company_name',
            'company',
            'company_title',
            'company_full_name',
          ]);
        }
        if (clientPosition.isEmpty) {
          clientPosition = _extractOrderField(lastOrder, [
            'company_position',
            'position',
            'company_role',
            'client_position',
          ]);
        }
      }

      if (mounted) {
        setState(() {
          // Populate combined full name
          _fullNameController.text = '${profile.name} ${profile.surname}'
              .trim();
          _phoneController.text = profile.phoneNumber;

          _companyController.text = companyName;
          _positionController.text = clientPosition;

          _isLoading = false;
        });
      }
    } catch (e) {
      // If client profile endpoint is missing (user hasn't created client profile yet),
      // try to fetch basic user info from /users/me and prefill name/surname without error.
      try {
        final authApi = sl<AuthApi>();
        final user = await authApi.getCurrentUser();
        final name = (user['name'] as String?)?.trim() ?? '';
        final surname = (user['surname'] as String?)?.trim() ?? '';
        final phone = (user['phone_number'] as String?)?.trim() ?? '';

        if (mounted) {
          setState(() {
            _fullNameController.text = '${name} ${surname}'.trim();
            _phoneController.text = phone;
            // Position and company remain empty — user hasn't created a client profile/order yet
            _companyController.text = '';
            _positionController.text = '';
            _isLoading = false;
          });
        }
        // Provide a short haptic to indicate limited profile
        HapticFeedback.mediumImpact();
      } catch (e2) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка загрузки профиля: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Helper to safely call getMyOrders and return a List<dynamic>
  Future<List<dynamic>> _api_service_get_my_orders_safe() async {
    try {
      final orders = await _apiService.getMyOrders(limit: 1, offset: 0);
      return orders;
    } catch (e) {
      // If API fails, return empty list
      return <dynamic>[];
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Split full name into name and surname for the existing use case
      final fullName = _fullNameController.text.trim();
      final parts = fullName.isEmpty
          ? <String>[]
          : fullName.split(RegExp(r'\s+'));
      final name = parts.isNotEmpty ? parts.first : '';
      final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      await _updateClientProfileUseCase(
        name: name,
        surname: surname,
        phoneNumber: _phoneController.text.trim(),
      );

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Профиль успешно сохранен'),
        //     backgroundColor: Colors.green,
        //   ),
        // );

        // Navigate back to My Orders
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при сохранении: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper to extract string value for given possible keys from an order map
  String _extractOrderField(Map<String, dynamic> order, List<String> keys) {
    // 1. Direct keys
    for (final key in keys) {
      final v = order[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }

    // 2. Nested under 'company' or similar
    final nestedCandidates = ['company', 'company_data', 'company_info'];
    for (final nKey in nestedCandidates) {
      final nested = order[nKey];
      if (nested is Map<String, dynamic>) {
        for (final key in keys) {
          final v = nested[key];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        // common name keys
        final name = nested['name'] ?? nested['company_name'];
        if (name is String && name.trim().isNotEmpty) return name.trim();
      }
    }

    // 3. Search for values in any nested maps
    for (final v in order.values) {
      if (v is Map<String, dynamic>) {
        for (final key in keys) {
          final candidate = v[key];
          if (candidate is String && candidate.trim().isNotEmpty)
            return candidate.trim();
        }
      }
    }

    // 4. Fallback: try to find any string value that looks like a company (heuristic)
    for (final v in order.values) {
      if (v is String && v.trim().length > 1) return v.trim();
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),

                        // Header: back arrow above the title (column layout as per Figma)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
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
                            SizedBox(height: 18.h),
                            Text(
                              'Мой профиль',
                              style: TextStyle(
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w700,
                                fontSize: 26.sp,
                                height: 1.149, // lineHeight from Figma
                                color: AppColors.primaryText,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Avatar with edit button (centered)
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120.r,
                                height: 120.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.lightGrayBackground,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 60.r,
                                  color: AppColors.primaryText.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              // Edit icon positioned bottom-right
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: implement avatar pick/upload
                                  },
                                  child: Container(
                                    width: 36.w,
                                    height: 36.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.inputBorderColor,
                                        width: 1,
                                      ),
                                    ),
                                    padding: EdgeInsets.all(6.w),
                                    child: SvgPicture.asset(
                                      'assets/svgs/edit_icon_profile.svg',
                                      colorFilter: ColorFilter.mode(
                                        AppColors.primaryText,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Form fields: Full name, Position, Company, Phone
                        Column(
                          children: [
                            _buildInputField(
                              label: 'Имя и фамилия',
                              controller: _fullNameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Введите имя и фамилию';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),

                            _buildInputField(
                              label: 'Должность',
                              controller: _positionController,
                              readOnly: true,
                              onTap: () {
                                // If position is empty, inform user they must create an order first
                                if (_positionController.text.trim().isEmpty) {
                                  HapticFeedback.heavyImpact();
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(
                                  //     content: Text(
                                  //       'Сначала создайте заказ, затем вы сможете редактировать профиль.',
                                  //     ),
                                  //     backgroundColor: Colors.orange,
                                  //   ),
                                  // );
                                }
                              },
                              validator: (value) {
                                // position is read-only
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),

                            _buildInputField(
                              label: 'Компания',
                              controller: _companyController,
                              readOnly: true,
                              onTap: () {
                                if (_companyController.text.trim().isEmpty) {
                                  HapticFeedback.heavyImpact();
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(
                                  //     content: Text(
                                  //       'Сначала создайте заказ, затем вы сможете редактировать профиль.',
                                  //     ),
                                  //     backgroundColor: Colors.orange,
                                  //   ),
                                  // );
                                }
                              },
                              validator: (value) {
                                // company is read-only
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),

                            _buildInputField(
                              label: 'Телефон',
                              controller: _phoneController,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Введите номер телефона';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 100.h), // 751 - 582 = 169
                        // Save button
                        SizedBox(
                          width: 354.w,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
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
                            child: _isSaving
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Сохранить',
                                    style: TextStyle(
                                      fontFamily: 'Ubuntu',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17.sp,
                                      height:
                                          1.149, // lineHeight: 1.1490000556497013em from Figma
                                      color: AppColors.white,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 52.h), // Bottom padding
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    Widget child = Container(
      width: 354.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.inputBorderColor, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                height: 1.0, // lineHeight: 1em from Figma
                color: AppColors.inputLabelColor,
              ),
            ),
            SizedBox(height: 2.h),

            // Input field
            TextFormField(
              controller: controller,
              readOnly: readOnly,
              enabled: !readOnly,
              validator: validator,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                height: 1.3, // lineHeight: 1.2999999523162842em from Figma
                color: Colors.black.withValues(
                  alpha: 0.8,
                ), // rgba(0, 0, 0, 0.8) from Figma
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );

    // If field is readOnly we want taps to be handled — e.g., show alert for empty position/company
    if (readOnly) {
      return GestureDetector(onTap: onTap, child: child);
    }

    return child;
  }
}
