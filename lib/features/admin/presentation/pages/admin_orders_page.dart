import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../data/repositories/admin_projects_repository.dart';
import '../../data/models/admin_project_model.dart';
import '../../data/models/admin_order_model.dart';
import '../../data/models/admin_client_model.dart';
import '../../data/models/admin_company_model.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/api/admin_api.dart';
import '../../../../shared/api/clients_api.dart';
import '../../../../shared/api/companies_api.dart';
import '../../../../shared/api/freelancer_api.dart';
import '../../../../shared/api/auth_api.dart';
import '../../../../shared/api/applications_api.dart';
import '../../../../shared/api/client.dart';
import '../../../../shared/models/company_option.dart';
import '../../../../shared/widgets/company_dropdown_field.dart';
import '../../../../features/orders/data/models/freelancer_model.dart';
import '../../../../features/orders/data/models/application_model.dart';
import '../widgets/specialization_dialog.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late final AdminProjectsRepository _repository;
  late final AuthApi _authApi;
  late final AdminApi _adminApi;
  late final FreelancerApi _freelancerApi;
  late final ApplicationsApi _applicationsApi;
  List<AdminProjectModel> _projects = const [];
  List<AdminProjectModel> _allProjects = const [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  String _selectedFilter = 'all';
  final Map<String, bool> _descriptionExpanded = {};
  String? _userDisplayName;
  late final CompaniesApi _companiesApi;
  final Map<String, List<AdminCompanyModel>> _clientCompanies = {};
  final Map<String, bool> _companiesLoading = {};
  final Map<String, String?> _selectedCompanyByOrder = {};
  final Map<String, AdminCompanyModel> _overrideCompanyByOrder = {};

  // Applications state
  final Map<String, List<ApplicationModel>> _ordersApplications = {};
  final Map<String, bool> _applicationsLoading = {};

  // Editing state
  final Map<String, bool> _editingFields = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _savingFields = {};

  // Applied freelancers state
  final Map<String, FreelancerModel> _appliedFreelancers = {};
  final Map<String, bool> _fetchingFreelancers = {};

  @override
  void initState() {
    super.initState();
    _repository = AdminProjectsRepository(
      adminApi: sl<AdminApi>(),
      clientsApi: sl<ClientsApi>(),
      companiesApi: sl<CompaniesApi>(),
    );
    _applicationsApi = sl<ApplicationsApi>();
    _authApi = sl<AuthApi>();
    _adminApi = sl<AdminApi>();
    _freelancerApi = sl<FreelancerApi>();
    _companiesApi = sl<CompaniesApi>();
    _loadUser();
    _loadProjects();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authApi.getCurrentUser();
      final data = user.isNotEmpty && user['data'] is Map<String, dynamic>
          ? user['data'] as Map<String, dynamic>
          : user;
      final name = (data['name'] as String?)?.trim() ?? '';
      final surname = (data['surname'] as String?)?.trim() ?? '';
      if (!mounted) {
        return;
      }
      setState(() {
        if (name.isNotEmpty || surname.isNotEmpty) {
          _userDisplayName = [
            name,
            surname,
          ].where((e) => e.isNotEmpty).join(' ');
        } else {
          _userDisplayName = 'Администратор';
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      // Debug: Print the error to understand what we're getting
      print('Auth error in _loadUser: $error');

      // Check for 403 unauthorized error and redirect to login
      if ((error is ApiException && error.statusCode == 403) ||
          error.toString().contains('403') ||
          error.toString().contains('Unauthorized') ||
          error.toString().contains('Forbidden') ||
          error.toString().contains('Access forbidden')) {
        print('Redirecting to login due to auth error');
        context.go('/manage/admin/panel/login');
        return;
      }

      setState(() {
        _userDisplayName = 'Администратор';
      });
    }
  }

  Future<void> _loadProjects([String? filterStatus]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final allProjects = await _repository.fetchProjects(status: 'all');
      if (!mounted) {
        return;
      }

      final filteredProjects = _filterProjects(
        allProjects,
        filterStatus ?? _selectedFilter,
      );

      final validOrderIds = allProjects
          .map((project) => project.order.id)
          .toSet();

      setState(() {
        _allProjects = allProjects;
        _projects = filteredProjects;
        if (_projects.isNotEmpty && _selectedIndex >= _projects.length) {
          _selectedIndex = 0;
        }
        _selectedCompanyByOrder.removeWhere(
          (orderId, _) => !validOrderIds.contains(orderId),
        );
        _overrideCompanyByOrder.removeWhere(
          (orderId, _) => !validOrderIds.contains(orderId),
        );
        _clientCompanies.removeWhere(
          (clientId, _) => !allProjects.any(
            (project) => project.client.clientId == clientId,
          ),
        );
        _ensureSelectionForProjects(allProjects);
        _isLoading = false;
      });

      // Fetch applied freelancers for all orders
      for (final project in filteredProjects) {
        _fetchAppliedFreelancers(project.order);
      }

      for (final project in filteredProjects) {
        _fetchCompaniesForClient(project.client.clientId);
      }

      if (_projects.isNotEmpty) {
        _fetchApplications(_projects[_selectedIndex].order.id);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      // Debug: Print the error to understand what we're getting
      print('Auth error in _loadProjects: $error');

      // Check for 403 unauthorized error and redirect to login
      if ((error is ApiException && error.statusCode == 403) ||
          error.toString().contains('403') ||
          error.toString().contains('Unauthorized') ||
          error.toString().contains('Forbidden') ||
          error.toString().contains('Access forbidden')) {
        print('Redirecting to login due to auth error');
        context.go('/manage/admin/panel/login');
        return;
      }

      setState(() {
        _errorMessage = 'Не удалось загрузить проекты';
        _projects = const [];
        _allProjects = const [];
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchApplications(String orderId) async {
    if (_ordersApplications.containsKey(orderId) ||
        (_applicationsLoading[orderId] ?? false)) {
      return;
    }

    setState(() {
      _applicationsLoading[orderId] = true;
    });

    try {
      final applications = await _applicationsApi.getOrderApplications(orderId);
      final pendingApplications = applications
          .where((app) => app.status == ApplicationStatus.pending)
          .toList();

      if (mounted) {
        setState(() {
          _ordersApplications[orderId] = pendingApplications;
          _applicationsLoading[orderId] = false;
        });

        // Fetch freelancer data for each application
        for (final app in pendingApplications) {
          _fetchFreelancerData(app.freelancerId);
        }
      }
    } catch (e) {
      debugPrint('Error fetching applications: $e');
      if (mounted) {
        setState(() {
          _applicationsLoading[orderId] = false;
        });
      }
    }
  }

  Future<void> _handleApplicationStatus(
    ApplicationModel app,
    ApplicationStatus status,
  ) async {
    try {
      await _applicationsApi.updateApplicationStatus(
        applicationId: app.id,
        status: status,
      );

      if (!mounted) return;

      // Refresh applications
      setState(() {
        _ordersApplications.remove(app.orderId);
      });
      _fetchApplications(app.orderId);

      // If accepted, we might want to refresh the project to show the new participant?
      // But maybe just updating status is enough for now.
      // Actually if accepted, it should ideally update the order's specializations as well?
      // The backend probably handles assigning the freelancer if accepted.
      // So we should re-fetch the project too.
      _loadProjects();
    } catch (e) {
      debugPrint('Error updating application status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления статуса: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchFreelancerData(String freelancerId) async {
    if (_appliedFreelancers.containsKey(freelancerId) ||
        _fetchingFreelancers[freelancerId] == true) {
      return; // Already fetched or fetching
    }

    setState(() {
      _fetchingFreelancers[freelancerId] = true;
    });

    try {
      final response = await _freelancerApi.getFreelancerById(freelancerId);
      final nestedData = response['data'];
      final freelancerData = nestedData is Map<String, dynamic>
          ? nestedData
          : response;
      final freelancer = FreelancerModel.fromJson(freelancerData);

      if (!mounted) return;

      setState(() {
        _appliedFreelancers[freelancerId] = freelancer;
        _fetchingFreelancers[freelancerId] = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _fetchingFreelancers[freelancerId] = false;
      });

      // Log error for debugging
      print('Error fetching freelancer $freelancerId: $error');
    }
  }

  void _fetchAppliedFreelancers(AdminOrderModel order) {
    // Fetch freelancers from order_colleagues
    for (final freelancerId in order.orderColleagues) {
      _fetchFreelancerData(freelancerId);
    }

    // Fetch freelancers from occupied specializations
    for (final specialization in order.specializations) {
      if (specialization.isOccupied == true &&
          specialization.occupiedByFreelancerId != null) {
        _fetchFreelancerData(specialization.occupiedByFreelancerId!);
      }
    }
  }

  void _showFreelancerDetails(FreelancerModel freelancer) {
    showDialog(
      context: context,
      builder: (context) => _FreelancerDetailsDialog(freelancer: freelancer),
    );
  }

  void _updateOrderInLocalState(
    String orderId,
    Map<String, dynamic> updatedOrderData,
  ) {
    if (!mounted) return;

    // Parse the updated order from the response
    final updatedOrder = AdminOrderModel.fromJson(updatedOrderData);

    setState(() {
      // Update in _allProjects
      for (int i = 0; i < _allProjects.length; i++) {
        if (_allProjects[i].order.id == orderId) {
          _allProjects[i] = AdminProjectModel(
            order: updatedOrder,
            client: _allProjects[i].client,
            company: _allProjects[i].company,
          );
          break;
        }
      }

      // Update in _projects (filtered list)
      for (int i = 0; i < _projects.length; i++) {
        if (_projects[i].order.id == orderId) {
          _projects[i] = AdminProjectModel(
            order: updatedOrder,
            client: _projects[i].client,
            company: _projects[i].company,
          );
          break;
        }
      }
    });
  }

  List<AdminProjectModel> _filterProjects(
    List<AdminProjectModel> projects,
    String filter,
  ) {
    switch (filter) {
      case 'pending':
        // "Жду запуска" - only pending orders that are not completed by admin
        return projects.where((project) {
          final status = project.order.status.toLowerCase();
          final completeStatus =
              project.order.completeStatus?.toLowerCase() ?? 'pending';
          return status == 'pending' && completeStatus == 'pending';
        }).toList();

      case 'approved':
        // "В работе" - only approved orders that are not ended
        return projects.where((project) {
          final status = project.order.status.toLowerCase();
          final completeStatus =
              project.order.completeStatus?.toLowerCase() ?? 'pending';
          return status == 'approved' && completeStatus != 'completed';
        }).toList();

      case 'completed':
        // "Завершен" - only ended and completed orders
        return projects.where((project) {
          final completeStatus =
              project.order.completeStatus?.toLowerCase() ?? 'pending';
          return completeStatus == 'completed';
        }).toList();

      case 'all':
      default:
        // "Все проекты" - all pending and approved orders (not completed)
        return projects.where((project) {
          final status = project.order.status.toLowerCase();
          return status == 'pending' || status == 'approved';
        }).toList();
    }
  }

  String? _companyKeyForOrder(AdminCompanyModel company, String orderId) {
    if (company.companyId.isNotEmpty) {
      return company.companyId;
    }
    final name = company.companyName;
    if (name == null || name.isEmpty) {
      return null;
    }
    return 'order_${orderId}_${name.hashCode}';
  }

  void _ensureSelectionForProjects(List<AdminProjectModel> projects) {
    for (final project in projects) {
      final orderId = project.order.id;
      if (_selectedCompanyByOrder.containsKey(orderId)) {
        continue;
      }
      final key = _companyKeyForOrder(project.company, orderId);
      if (key != null) {
        _selectedCompanyByOrder[orderId] = key;
      }
    }
  }

  Future<void> _fetchCompaniesForClient(String clientId) async {
    if (clientId.isEmpty) {
      return;
    }
    if (_clientCompanies.containsKey(clientId) ||
        _companiesLoading[clientId] == true) {
      return;
    }
    setState(() {
      _companiesLoading[clientId] = true;
    });
    try {
      final response = await _companiesApi.getCompaniesByClientId(clientId);
      if (!mounted) {
        return;
      }
      final companies = response
          .map(AdminCompanyModel.fromJson)
          .toList(growable: false);

      final idSet = companies.map((company) => company.companyId).toSet();
      final nameMap = <String, AdminCompanyModel>{};
      for (final company in companies) {
        final name = company.companyName;
        if (company.companyId.isEmpty || name == null || name.isEmpty) {
          continue;
        }
        nameMap[name.toLowerCase()] = company;
      }

      final selectedUpdates = <String, String>{};
      final overrideUpdates = <String, AdminCompanyModel>{};

      for (final project in _allProjects.where(
        (item) => item.client.clientId == clientId,
      )) {
        final orderId = project.order.id;
        final overrideCompany = _overrideCompanyByOrder[orderId];
        if (overrideCompany != null) {
          final name = overrideCompany.companyName;
          if (name != null && name.isNotEmpty) {
            final match = nameMap[name.toLowerCase()];
            if (match != null) {
              selectedUpdates[orderId] = match.companyId;
              overrideUpdates[orderId] = match;
            }
          }
          continue;
        }

        final currentSelectedId = _selectedCompanyByOrder[orderId];
        if (currentSelectedId != null && idSet.contains(currentSelectedId)) {
          continue;
        }

        final fallbackName = project.company.companyName;
        if (fallbackName == null || fallbackName.isEmpty) {
          continue;
        }
        final match = nameMap[fallbackName.toLowerCase()];
        if (match != null) {
          selectedUpdates[orderId] = match.companyId;
        }
      }

      setState(() {
        _clientCompanies[clientId] = companies;
        for (final entry in selectedUpdates.entries) {
          _selectedCompanyByOrder[entry.key] = entry.value;
        }
        for (final entry in overrideUpdates.entries) {
          _overrideCompanyByOrder[entry.key] = entry.value;
        }
        _companiesLoading[clientId] = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _companiesLoading[clientId] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось загрузить компании клиента: $error'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  AdminCompanyModel _resolveCompany(
    AdminOrderModel order,
    AdminClientModel client,
    AdminCompanyModel fallback,
  ) {
    final override = _overrideCompanyByOrder[order.id];
    if (override != null) {
      return override;
    }

    final selectedId = _selectedCompanyByOrder[order.id];
    final companies = _clientCompanies[client.clientId];
    if (selectedId != null && companies != null) {
      for (final company in companies) {
        if (company.companyId == selectedId) {
          return company;
        }
      }
    }

    final fallbackKey = _companyKeyForOrder(fallback, order.id);
    if (selectedId != null &&
        fallbackKey != null &&
        selectedId == fallbackKey) {
      return fallback;
    }

    if (companies != null && fallback.companyName != null) {
      for (final company in companies) {
        if (company.companyName == fallback.companyName) {
          return company;
        }
      }
    }

    return fallback;
  }

  void _selectFilter(String filter) {
    if (_selectedFilter == filter) return;

    setState(() {
      _selectedFilter = filter;
      _projects = _filterProjects(_allProjects, filter);
      _selectedIndex = 0; // Reset selection when filter changes
      _ensureSelectionForProjects(_projects);
    });

    for (final project in _projects) {
      _fetchCompaniesForClient(project.client.clientId);
    }
  }

  void _selectProject(int index) {
    if (_projects.isEmpty) {
      return;
    }
    if (index < 0 || index >= _projects.length) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    _fetchCompaniesForClient(_projects[index].client.clientId);
    _fetchApplications(_projects[index].order.id);
  }

  void _toggleDescription(String orderId) {
    setState(() {
      final current = _descriptionExpanded[orderId] ?? false;
      _descriptionExpanded[orderId] = !current;
    });
  }

  void _startEditingField(String fieldKey, String initialValue) {
    setState(() {
      _editingFields[fieldKey] = true;
      if (!_controllers.containsKey(fieldKey)) {
        _controllers[fieldKey] = TextEditingController(text: initialValue);
      } else {
        _controllers[fieldKey]!.text = initialValue;
      }
    });
  }

  void _cancelEditingField(String fieldKey) {
    setState(() {
      _editingFields[fieldKey] = false;
    });
  }

  Future<void> _saveDescription(String orderId, String newDescription) async {
    final fieldKey = 'description_$orderId';
    setState(() {
      _savingFields[fieldKey] = true;
    });

    try {
      final response = await _adminApi.completeOrder(
        orderId: orderId,
        orderDescription: newDescription,
      );

      // Update only the specific order in local state
      _updateOrderInLocalState(orderId, response);

      setState(() {
        _editingFields[fieldKey] = false;
        _savingFields[fieldKey] = false;
      });
    } catch (error) {
      setState(() {
        _savingFields[fieldKey] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChatLink(String orderId, String newChatLink) async {
    final fieldKey = 'chatLink_$orderId';
    setState(() {
      _savingFields[fieldKey] = true;
    });

    try {
      final response = await _adminApi.completeOrder(
        orderId: orderId,
        orderDescription: _projects[_selectedIndex].order.description ?? '',
        chatLink: newChatLink,
      );

      // Update only the specific order in local state
      _updateOrderInLocalState(orderId, response);

      setState(() {
        _savingFields[fieldKey] = false;
      });

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Чат проекта успешно обновлен'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }
    } catch (error) {
      setState(() {
        _savingFields[fieldKey] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveCompanyName(
    AdminOrderModel order,
    AdminCompanyModel company,
    String newName,
  ) async {
    final fieldKey = 'companyName_${order.id}';
    setState(() {
      _savingFields[fieldKey] = true;
    });

    try {
      if (company.companyId.isEmpty) {
        throw Exception('Company id missing');
      }

      final response = await _companiesApi.updateCompany(
        company.companyId,
        companyName: newName.trim(),
      );

      final updatedCompany = AdminCompanyModel.fromJson(response);

      if (!mounted) return;

      setState(() {
        // Override for this specific order view
        _overrideCompanyByOrder[order.id] = updatedCompany;

        // Update projects lists where this order appears
        _projects = _projects.map((p) {
          if (p.order.id == order.id) {
            return AdminProjectModel(
              order: p.order,
              client: p.client,
              company: updatedCompany,
            );
          }
          return p;
        }).toList();

        _allProjects = _allProjects.map((p) {
          if (p.order.id == order.id) {
            return AdminProjectModel(
              order: p.order,
              client: p.client,
              company: updatedCompany,
            );
          }
          return p;
        }).toList();

        _editingFields[fieldKey] = false;
        _savingFields[fieldKey] = false;
      });
    } catch (error) {
      setState(() {
        _savingFields[fieldKey] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showChatLinkEditDialog(String orderId, String? currentChatLink) {
    final controller = TextEditingController(text: currentChatLink ?? '');

    showDialog(
      context: context,
      builder: (context) => _ChatLinkEditDialog(
        controller: controller,
        onSave: (newChatLink) {
          Navigator.of(context).pop();
          _saveChatLink(orderId, newChatLink);
        },
        isSaving: _savingFields['chatLink_$orderId'] ?? false,
      ),
    );
  }

  Future<void> _saveOrderSpecialization(
    AdminOrderModel order,
    Map<String, dynamic> payload,
  ) async {
    // Get existing specializations
    final existingSpecializations = order.specializations
        .map(
          (spec) => {
            'specialization': spec.specialization,
            'requirements': spec.requirements,
            'skill_level': spec.skillLevel,
            'conditions': spec.conditions != null
                ? {
                    'salary': spec.conditions!.salary,
                    'pay_per': spec.conditions!.payPer,
                    'required_experience': spec.conditions!.requiredExperience,
                    'schedule_type': spec.conditions!.scheduleType,
                    'format_type': spec.conditions!.formatType,
                  }
                : null,
          },
        )
        .toList();

    // Add or update the specialization
    final updatedSpecializations = [...existingSpecializations, payload];

    final response = await _adminApi.completeOrder(
      orderId: order.id,
      orderDescription: order.description ?? '',
      orderSpecializations: updatedSpecializations,
    );

    _updateOrderInLocalState(order.id, response);

    if (!mounted) return;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Специализация успешно обновлена'),
    //     backgroundColor: Colors.green,
    //   ),
    // );
  }

  void _openSpecializationModal({
    AdminOrderColleagueModel? colleague,
    AdminOrderSpecializationModel? specialization,
  }) {
    if (_projects.isEmpty ||
        _selectedIndex < 0 ||
        _selectedIndex >= _projects.length) {
      return;
    }

    final order = _projects[_selectedIndex].order;

    showGeneralDialog(
      context: context,
      barrierLabel: 'Закрыть',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AddOrderSpecializationModal(
          initialSpecialization: specialization,
          onCancel: () => Navigator.of(context).pop(),
          onSubmit: (payload) => _saveOrderSpecialization(order, payload),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  Future<void> _openLink(String value) async {
    var url = value.trim();
    if (url.isEmpty) {
      return;
    }
    if (!url.startsWith('http') && !url.startsWith('https')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Text(
            'Админ панель доступна только на вебе',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: AppColors.adminPrimaryText,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      body: Column(
        children: [
          _buildTopBar(),
          _buildFiltersBar(),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final displayName = _userDisplayName ?? 'Администратор';
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                SvgPicture.asset('assets/svgs/collab_logo.svg', height: 28),
                const SizedBox(width: 40),
                _buildTopNavItem('Проекты', active: true),
                const SizedBox(width: 24),
                _buildTopNavItem('Заказчики'),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: () => context.go('/admin/freelancers'),
                  child: _buildTopNavItem('Исполнители'),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: AppColors.adminPrimaryText,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () async {
                        await _authApi.logout();
                        if (mounted) {
                          context.go('/manage/admin/panel/login');
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        foregroundColor: AppColors.adminAccentBlue,
                        textStyle: const TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      child: const Text('выйти'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavItem(String label, {bool active = false}) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        fontSize: 16,
        color: active
            ? AppColors.adminPrimaryText
            : AppColors.adminSecondaryText,
      ),
    );
  }

  Widget _buildFiltersBar() {
    // Calculate status counts from all projects
    final pendingCount = _filterProjects(_allProjects, 'pending').length;
    final approvedCount = _filterProjects(_allProjects, 'approved').length;
    final completedCount = _filterProjects(_allProjects, 'completed').length;
    final allActiveCount = _filterProjects(_allProjects, 'all').length;

    final filters = [
      _AdminFilter(
        label: 'Все проекты',
        count: allActiveCount,
        active: _selectedFilter == 'all',
        filterKey: 'all',
      ),
      _AdminFilter(
        label: 'Жду запуска',
        count: pendingCount,
        active: _selectedFilter == 'pending',
        filterKey: 'pending',
      ),
      _AdminFilter(
        label: 'В работе',
        count: approvedCount,
        active: _selectedFilter == 'approved',
        filterKey: 'approved',
      ),
      _AdminFilter(
        label: 'Завершен',
        count: completedCount,
        active: _selectedFilter == 'completed',
        filterKey: 'completed',
      ),
    ];
    return Container(
      height: 52,
      color: AppColors.black,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: filters
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _AdminFilterChip(
                        filter: filter,
                        onTap: () => _selectFilter(filter.filterKey),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        color: AppColors.adminSidebar,
        border: Border(right: BorderSide(color: AppColors.adminDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Проекты',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.adminPrimaryText,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _buildSidebarError()
                  : _projects.isEmpty
                  ? _buildSidebarEmpty()
                  : ListView.separated(
                      itemCount: _projects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final project = _projects[index];
                        final selected = index == _selectedIndex;
                        return _AdminSidebarItem(
                          project: project,
                          selected: selected,
                          onTap: () => _selectProject(index),
                          statusLabel: _statusLabel(project.order.status),
                          statusColor: _statusColor(project.order.status),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _errorMessage ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.adminSecondaryText,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loadProjects,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminAccentBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Обновить'),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarEmpty() {
    return Center(
      child: Text(
        'Нет активных проектов',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: AppColors.adminSecondaryText,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.adminSecondaryText,
          ),
        ),
      );
    }
    if (_projects.isEmpty) {
      return Center(
        child: Text(
          'Выберите проект в левой панели',
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.adminSecondaryText,
          ),
        ),
      );
    }
    final project = _projects[_selectedIndex];
    final order = project.order;
    final client = project.client;
    final baseCompany = project.company;
    final company = _resolveCompany(order, client, baseCompany);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProjectTitle(order, company),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _statusLabel(order.status),
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _statusColor(order.status),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDescriptionCard(order),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _AdminCard(
                    title: 'Документы',
                    child: _buildContracts(order.contracts),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _AdminCard(
                    title: 'Чат проекта',
                    trailing: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.adminAccentBlue.withAlpha(31),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.adminAccentBlue.withAlpha(51),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () =>
                              _showChatLinkEditDialog(order.id, order.chatLink),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: AppColors.adminAccentBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: _buildChat(order.chatLink),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _AdminCard(
                    title: 'Заказчик',
                    child: _buildClientInfo(
                      order,
                      client,
                      baseCompany,
                      company,
                    ),
                  ),
                ),
              ],
            ),
            _buildApplicationsSection(order.id),
            const SizedBox(height: 32),
            Text(
              'Участники',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.adminPrimaryText,
              ),
            ),
            const SizedBox(height: 20),
            _buildParticipants(order.colleagues),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTitle(AdminOrderModel order, AdminCompanyModel company) {
    final fieldKey = 'companyName_${order.id}';
    final isEditing = _editingFields[fieldKey] ?? false;
    final isSaving = _savingFields[fieldKey] ?? false;
    final companyName = company.companyName?.isNotEmpty == true
        ? company.companyName!
        : order.title ?? 'Проект';

    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCADDE1), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _controllers[fieldKey],
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: Color(0xFF353F49),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Название компании',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 130,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0x0D000000),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: isSaving
                      ? null
                      : () => _cancelEditingField(fieldKey),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: const Color(0xFF353F49),
                    textStyle: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  child: const Text('Отменить'),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 130,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          final newName = _controllers[fieldKey]?.text ?? '';
                          _saveCompanyName(order, company, newName);
                        },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
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
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            companyName,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w700,
              fontSize: 28,
              color: AppColors.adminPrimaryText,
            ),
          ),
        ),
        if (company.companyId.isNotEmpty)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.adminAccentBlue.withAlpha(31),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.adminAccentBlue.withAlpha(51),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _startEditingField(fieldKey, companyName),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: AppColors.adminAccentBlue,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionCard(AdminOrderModel order) {
    final fieldKey = 'description_${order.id}';
    final isEditing = _editingFields[fieldKey] ?? false;
    final isSaving = _savingFields[fieldKey] ?? false;
    final description = order.description?.trim() ?? '';
    final isExpanded = _descriptionExpanded[order.id] ?? false;
    final hasLongDescription =
        description.length > 280 || description.split('\n').length > 4;

    if (isEditing) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Описание проекта:',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.adminPrimaryText,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCADDE1), width: 0.9),
                borderRadius: BorderRadius.circular(12.58),
              ),
              child: TextField(
                controller: _controllers[fieldKey],
                maxLines: null,
                minLines: 8,
                style: const TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  height: 1.3,
                  color: Color(0xCC000000), // rgba(0, 0, 0, 0.8)
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                  hintText: 'Введите описание проекта...',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 150,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x0D000000), // rgba(0, 0, 0, 0.05)
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: isSaving
                        ? null
                        : () => _cancelEditingField(fieldKey),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: const Color(0xFF353F49),
                      textStyle: const TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        height: 1.149,
                      ),
                    ),
                    child: const Text('Отменить'),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: 150,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            final newDescription =
                                _controllers[fieldKey]?.text ?? '';
                            _saveDescription(order.id, newDescription);
                          },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        height: 1.149,
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
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
              ],
            ),
          ],
        ),
      );
    }

    return _AdminCard(
      title: 'Описание проекта',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLongDescription)
            TextButton(
              onPressed: () => _toggleDescription(order.id),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: AppColors.adminAccentBlue,
                textStyle: const TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              child: Text(isExpanded ? 'Скрыть' : 'Показать целиком'),
            ),
          if (hasLongDescription) const SizedBox(width: 16),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.adminAccentBlue.withAlpha(31),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.adminAccentBlue.withAlpha(51),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  _startEditingField(fieldKey, description);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: AppColors.adminAccentBlue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: Text(
        description.isEmpty ? 'Описание не заполнено' : description,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.5,
          color: AppColors.adminPrimaryText,
        ),
        maxLines: hasLongDescription && !isExpanded ? 6 : null,
        overflow: hasLongDescription && !isExpanded
            ? TextOverflow.ellipsis
            : TextOverflow.visible,
      ),
    );
  }

  Widget _buildContracts(List<AdminOrderContractModel> contracts) {
    if (contracts.isEmpty) {
      return Text(
        'Нет прикрепленных документов',
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: AppColors.adminSecondaryText,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contracts.map((contract) {
        final status = contract.status ?? 'драфт';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  contract.title ?? 'Контракт',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: AppColors.adminPrimaryText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.adminBadgeNeutral,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.adminPrimaryText,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChat(String? chatLink) {
    if (chatLink == null || chatLink.isEmpty) {
      return Text(
        'Чат не указан',
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: AppColors.adminSecondaryText,
        ),
      );
    }
    return GestureDetector(
      onTap: () => _openLink(chatLink),
      child: Text(
        chatLink,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: AppColors.adminAccentBlue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildClientInfo(
    AdminOrderModel order,
    AdminClientModel client,
    AdminCompanyModel fallbackCompany,
    AdminCompanyModel selectedCompany,
  ) {
    final clientId = client.clientId;
    final companies = _clientCompanies[clientId] ?? const <AdminCompanyModel>[];
    final isLoading = _companiesLoading[clientId] ?? false;

    final optionMap = <String, AdminCompanyModel>{};
    for (final company in companies) {
      final key = _companyKeyForOrder(company, order.id);
      if (key != null) {
        optionMap[key] = company;
      }
    }

    final fallbackKey = _companyKeyForOrder(fallbackCompany, order.id);
    if (fallbackKey != null && !optionMap.containsKey(fallbackKey)) {
      optionMap[fallbackKey] = fallbackCompany;
    }

    final resolvedKey = _companyKeyForOrder(selectedCompany, order.id);
    if (resolvedKey != null && !optionMap.containsKey(resolvedKey)) {
      optionMap[resolvedKey] = selectedCompany;
    }

    final options =
        optionMap.entries
            .map(
              (entry) => CompanyOption(
                id: entry.key,
                name: entry.value.companyName?.isNotEmpty == true
                    ? entry.value.companyName!
                    : client.displayName,
                subtitle: entry.value.clientPosition,
              ),
            )
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    final selectedId =
        _selectedCompanyByOrder[order.id] ?? resolvedKey ?? fallbackKey;
    final activeCompany =
        selectedId != null && optionMap.containsKey(selectedId)
        ? optionMap[selectedId]!
        : selectedCompany;

    final dropdownStyle = CompanyDropdownStyle(
      labelPadding: EdgeInsets.zero,
      labelStyle: TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: AppColors.adminSecondaryText.withOpacity(0.9),
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: Colors.redAccent,
      ),
      fieldPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      fieldBorderRadius: BorderRadius.circular(8),
      fieldBorder: const Border(
        bottom: BorderSide(color: Color(0x14353F49), width: 1),
      ),
      fieldBackgroundColor: Colors.transparent,
      trailingIcon: const Icon(
        Icons.expand_more,
        size: 20,
        color: Color(0xFF2782E3),
      ),
      valueStyle: const TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        fontSize: 17,
        color: Color(0xFF2782E3),
      ),
      placeholderStyle: const TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        fontSize: 17,
        color: Color(0xFFBCC5C7),
      ),
      dropdownPadding: const EdgeInsets.fromLTRB(20, 32, 16, 32),
      dropdownBorderRadius: BorderRadius.circular(16),
      dropdownShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 25,
          offset: const Offset(0, 0),
          spreadRadius: -5,
        ),
      ],
      dropdownBackgroundColor: Colors.white,
      dropdownItemStyle: const TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        fontSize: 17,
        color: Color(0xFF353F49),
      ),
      dropdownSelectedItemStyle: const TextStyle(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        fontSize: 17,
        color: Color(0xFF2782E3),
      ),
      dropdownSelectedIconColor: const Color(0xFF2782E3),
      dropdownItemSpacing: 16,
      overlayVerticalOffset: 12,
      dropdownMaxHeight: 360,
      dropdownWidth: 227,
      dropdownOffset: Offset.zero,
      fieldHeight: 36,
    );

    final displayName = activeCompany.companyName?.isNotEmpty == true
        ? activeCompany.companyName!
        : client.displayName;
    final position = activeCompany.clientPosition ?? 'Контактное лицо';
    final phone = client.phoneNumber ?? 'Номер не указан';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompanyDropdownField(
          label: 'Заказчик',
          options: options,
          selectedOptionId: selectedId,
          style: dropdownStyle,
          isLoading: isLoading && options.isEmpty,
          enabled: options.isNotEmpty,
          onOptionSelected: (option) {
            final selectedModel = optionMap[option.id] ?? activeCompany;
            setState(() {
              _selectedCompanyByOrder[order.id] = option.id;
              _overrideCompanyByOrder[order.id] = selectedModel;
            });
          },
          placeholder: displayName,
        ),
        const SizedBox(height: 12),
        Text(
          client.displayName,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.adminPrimaryText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          position,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.adminSecondaryText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          phone,
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: AppColors.adminPrimaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationsSection(String orderId) {
    final applications = _ordersApplications[orderId];
    final isLoading = _applicationsLoading[orderId] ?? false;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (applications == null || applications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'Заявки',
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.adminPrimaryText,
          ),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: applications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final app = applications[index];
            final freelancer = _appliedFreelancers[app.freelancerId];

            return _OrderApplicationCard(
              application: app,
              freelancer: freelancer,
              onAccept: () =>
                  _handleApplicationStatus(app, ApplicationStatus.accepted),
              onReject: () =>
                  _handleApplicationStatus(app, ApplicationStatus.rejected),
            );
          },
        ),
      ],
    );
  }

  Widget _buildParticipants(List<AdminOrderColleagueModel> colleagues) {
    final currentOrder =
        _projects.isNotEmpty &&
            _selectedIndex >= 0 &&
            _selectedIndex < _projects.length
        ? _projects[_selectedIndex].order
        : null;

    final List<Widget> cards = [];

    // Add filled position cards for colleagues (legacy support)
    for (final colleague in colleagues) {
      cards.add(
        _ParticipantCard(
          colleague: colleague,
          onTap: () => _openSpecializationModal(colleague: colleague),
        ),
      );
    }

    if (currentOrder != null) {
      // Process each specialization to show occupied or empty positions
      for (final specialization in currentOrder.specializations) {
        if (specialization.isOccupied == true &&
            specialization.occupiedByFreelancerId != null) {
          // Show occupied specialization with freelancer data
          final freelancerId = specialization.occupiedByFreelancerId!;

          if (_fetchingFreelancers[freelancerId] == true) {
            cards.add(_LoadingFreelancerCard(freelancerId: freelancerId));
          } else if (_appliedFreelancers.containsKey(freelancerId)) {
            final freelancer = _appliedFreelancers[freelancerId]!;
            cards.add(
              _OccupiedSpecializationCard(
                freelancer: freelancer,
                specialization: specialization,
                onTap: () => _showFreelancerDetails(freelancer),
              ),
            );
          } else {
            // Fetch freelancer data if not already fetched
            _fetchFreelancerData(freelancerId);
            cards.add(_LoadingFreelancerCard(freelancerId: freelancerId));
          }
        } else if (specialization.specialization != null) {
          // Show empty specialization position
          cards.add(
            _EmptyPositionCard(
              specialization: specialization,
              onTap: () =>
                  _openSpecializationModal(specialization: specialization),
            ),
          );
        }
      }

      // Add any additional applied freelancers from order_colleagues that aren't in specializations
      final occupiedFreelancerIds = currentOrder.specializations
          .where(
            (spec) =>
                spec.isOccupied == true && spec.occupiedByFreelancerId != null,
          )
          .map((spec) => spec.occupiedByFreelancerId!)
          .toSet();

      for (final freelancerId in currentOrder.orderColleagues) {
        if (!occupiedFreelancerIds.contains(freelancerId)) {
          if (_fetchingFreelancers[freelancerId] == true) {
            cards.add(_LoadingFreelancerCard(freelancerId: freelancerId));
          } else if (_appliedFreelancers.containsKey(freelancerId)) {
            final freelancer = _appliedFreelancers[freelancerId]!;
            cards.add(
              _AppliedFreelancerCard(
                freelancer: freelancer,
                onTap: () => _showFreelancerDetails(freelancer),
              ),
            );
          }
        }
      }
    }

    // Add "Add position" card
    cards.add(_AddParticipantCard(onPressed: () => _openSpecializationModal()));

    return Wrap(spacing: 27, runSpacing: 27, children: cards);
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Ждет запуска';
      case 'approved':
        return 'В работе';
      case 'completed':
        return 'Завершен';
      case 'on_hold':
        return 'На паузе';
      default:
        return status.isEmpty ? 'Без статуса' : status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.adminAccentBlue;
      case 'approved':
        return AppColors.adminAccentGreen;
      case 'completed':
        return AppColors.black;
      case 'on_hold':
        return AppColors.adminAccentOrange;
      default:
        return AppColors.adminSecondaryText;
    }
  }
}

class _ChatLinkEditDialog extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSave;
  final bool isSaving;

  const _ChatLinkEditDialog({
    required this.controller,
    required this.onSave,
    required this.isSaving,
  });

  @override
  State<_ChatLinkEditDialog> createState() => _ChatLinkEditDialogState();
}

class _ChatLinkEditDialogState extends State<_ChatLinkEditDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Чат проекта',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.adminPrimaryText,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFCADDE1),
                    width: 0.9,
                  ),
                  borderRadius: BorderRadius.circular(12.58),
                ),
                child: TextField(
                  controller: widget.controller,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    height: 1.3,
                    color: Color(0xCC000000), // rgba(0, 0, 0, 0.8)
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    hintText: 't.me/cl-project1',
                    hintStyle: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Color(0x66000000), // rgba(0, 0, 0, 0.4)
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 150,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0x0D000000), // rgba(0, 0, 0, 0.05)
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: widget.isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: const Color(0xFF353F49),
                        textStyle: const TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          height: 1.149,
                        ),
                      ),
                      child: const Text('Отменить'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 150,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: widget.isSaving
                          ? null
                          : () => widget.onSave(widget.controller.text.trim()),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          height: 1.149,
                        ),
                      ),
                      child: widget.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminFilter {
  final String label;
  final int count;
  final bool active;
  final String filterKey;

  const _AdminFilter({
    required this.label,
    required this.count,
    required this.filterKey,
    this.active = false,
  });
}

class _AdminFilterChip extends StatelessWidget {
  final _AdminFilter filter;
  final VoidCallback? onTap;

  const _AdminFilterChip({required this.filter, this.onTap});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = filter.active
        ? Colors.white
        : const Color.fromRGBO(255, 255, 255, 0.08);
    final textColor = filter.active ? AppColors.black : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter.label,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: filter.active
                    ? AppColors.adminAccentBlue.withAlpha(31)
                    : const Color.fromRGBO(255, 255, 255, 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                filter.count.toString(),
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: filter.active
                      ? AppColors.adminAccentBlue
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSidebarItem extends StatelessWidget {
  final AdminProjectModel project;
  final bool selected;
  final VoidCallback onTap;
  final String statusLabel;
  final Color statusColor;

  const _AdminSidebarItem({
    required this.project,
    required this.selected,
    required this.onTap,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected ? Colors.white : AppColors.adminSidebar;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.adminAccentBlue : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.adminAccentBlue.withAlpha(31),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.adminPrimaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                statusLabel,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _AdminCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: AppColors.adminPrimaryText,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final AdminOrderColleagueModel colleague;
  final VoidCallback? onTap;

  const _ParticipantCard({required this.colleague, this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = colleague.displayName.isEmpty
        ? 'Специалист'
        : colleague.displayName;
    final role = colleague.position ?? colleague.role ?? 'Без роли';
    final rateValue = colleague.rate;
    final rateUnit = colleague.rateUnit ?? '/час';
    final String rateText;
    if (rateValue != null && rateValue > 0) {
      final num value = rateValue;
      rateText = '${value.toStringAsFixed(0)} ₸ $rateUnit';
    } else {
      rateText = 'Ставка не указана';
    }

    // Default skill level to 'junior' since colleague model doesn't have skillLevel
    const skillLevel = 'junior';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 195,
        height: 176,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: ClipOval(
                child:
                    colleague.avatarUrl != null &&
                        colleague.avatarUrl!.isNotEmpty
                    ? Image.network(
                        colleague.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildAvatarFallback(name),
                      )
                    : _buildAvatarFallback(name),
              ),
            ),
            const SizedBox(height: 14),
            // Text content
            Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.69,
                    color: Color(0xFF353F49),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: Color(0xFF96A4B3),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  rateText,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 11.12,
                    color: Color(0xFF353F49),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Skill level badge positioned at bottom right
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 1, 6, 2),
                  decoration: BoxDecoration(
                    color: _getSkillLevelColor(skillLevel),
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: Text(
                    _getSkillLevelLabel(skillLevel),
                    style: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD9D9D9),
      ),
      child: Center(
        child: Text(
          name.characters.first.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF96A4B3),
          ),
        ),
      ),
    );
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'junior':
        return const Color(0xFF51B24F);
      case 'middle':
        return const Color(0xFF2782E3);
      case 'senior':
        return const Color(0xFFFB984D);
      default:
        return const Color(0xFF51B24F);
    }
  }

  String _getSkillLevelLabel(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'junior':
        return 'JUN';
      case 'middle':
        return 'MID';
      case 'senior':
        return 'SEN';
      default:
        return 'JUN';
    }
  }
}

class _EmptyPositionCard extends StatelessWidget {
  final AdminOrderSpecializationModel specialization;
  final VoidCallback? onTap;

  const _EmptyPositionCard({required this.specialization, this.onTap});

  @override
  Widget build(BuildContext context) {
    final role = specialization.specialization ?? 'Пустая позиция';
    final skillLevel = specialization.skillLevel?.toLowerCase() ?? 'junior';
    final conditions = specialization.conditions;
    final String rateText;

    if (conditions?.salary != null && conditions!.salary! > 0) {
      final payPer = conditions.payPer ?? 'час';
      rateText = '${conditions.salary!.toStringAsFixed(0)} ₸/$payPer';
    } else {
      rateText = '10 000 ₸/час';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 195,
        height: 176,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4DF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text content only for empty positions
            SizedBox(
              width: 157,
              child: Column(
                children: [
                  const Text(
                    'Пустая позиция',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: Color(0xFF96A4B3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 124,
                    child: Text(
                      '$role\n${_getSkillLevelLabel(skillLevel).toLowerCase()}',
                      style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 13.69,
                        color: Color(0xFF353F49),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rateText,
                    style: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 11.12,
                      color: Color(0xFF353F49),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSkillLevelLabel(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'junior':
        return 'Junior';
      case 'middle':
        return 'Middle';
      case 'senior':
        return 'Senior';
      default:
        return 'Junior';
    }
  }
}

class _AddParticipantCard extends StatelessWidget {
  final VoidCallback? onPressed;

  const _AddParticipantCard({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 195,
        height: 176,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCADDE1), width: 0.86),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar with plus icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                border: Border.all(color: const Color(0xFFCADDE1), width: 1),
              ),
              child: const Center(
                child: Icon(Icons.add, size: 36, color: Color(0xFF96A4B3)),
              ),
            ),
            const SizedBox(height: 14),
            // Text content
            const Text(
              'Добавить позицию',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w500,
                fontSize: 13.69,
                color: Color(0xFF353F49),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Applied Freelancer Card for showing applied freelancers
class _AppliedFreelancerCard extends StatelessWidget {
  final FreelancerModel freelancer;
  final VoidCallback? onTap;

  const _AppliedFreelancerCard({required this.freelancer, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 195,
        height: 176,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(
            34,
            139,
            34,
            0.1,
          ), // Light green background for applied freelancers
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF51B24F), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: ClipOval(
                child:
                    freelancer.avatarUrl != null &&
                        freelancer.avatarUrl!.isNotEmpty
                    ? Image.network(
                        freelancer.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildAvatarFallback(freelancer.fullName),
                      )
                    : _buildAvatarFallback(freelancer.fullName),
              ),
            ),
            const SizedBox(height: 14),
            // Text content
            Column(
              children: [
                Text(
                  freelancer.fullName,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.69,
                    color: Color(0xFF353F49),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  freelancer.primarySpecialization,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: Color(0xFF96A4B3),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Откликнулся',
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 11.12,
                    color: Color(0xFF51B24F),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Skill level badge positioned at bottom right
            if (freelancer.specializationsWithLevels.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 1, 6, 2),
                    decoration: BoxDecoration(
                      color: _getSkillLevelColor(
                        freelancer.specializationsWithLevels.first.skillLevel ??
                            'junior',
                      ),
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: Text(
                      _getSkillLevelLabel(
                        freelancer.specializationsWithLevels.first.skillLevel ??
                            'junior',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD9D9D9),
      ),
      child: Center(
        child: Text(
          name.characters.first.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF96A4B3),
          ),
        ),
      ),
    );
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'junior':
        return const Color(0xFF51B24F);
      case 'middle':
        return const Color(0xFF2782E3);
      case 'senior':
        return const Color(0xFFFB984D);
      default:
        return const Color(0xFF51B24F);
    }
  }

  String _getSkillLevelLabel(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'junior':
        return 'JUN';
      case 'middle':
        return 'MID';
      case 'senior':
        return 'SEN';
      default:
        return 'JUN';
    }
  }
}

// Loading Freelancer Card for when freelancer data is being fetched
class _LoadingFreelancerCard extends StatelessWidget {
  final String freelancerId;

  const _LoadingFreelancerCard({required this.freelancerId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 195,
      height: 176,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading avatar placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD9D9D9),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF96A4B3)),
              ),
            ),
          ),
          SizedBox(height: 14),
          // Loading text
          Text(
            'Загрузка...',
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 13.69,
              color: Color(0xFF96A4B3),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Freelancer Details Dialog
class _FreelancerDetailsDialog extends StatelessWidget {
  final FreelancerModel freelancer;

  const _FreelancerDetailsDialog({required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: ClipOval(
                      child:
                          freelancer.avatarUrl != null &&
                              freelancer.avatarUrl!.isNotEmpty
                          ? Image.network(
                              freelancer.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildAvatarFallback(),
                            )
                          : _buildAvatarFallback(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          freelancer.fullName,
                          style: const TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Color(0xFF353F49),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          freelancer.specializationWithLevel,
                          style: const TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFF96A4B3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact Info
              _buildInfoRow('Email', freelancer.email),
              _buildInfoRow('Телефон', freelancer.phoneNumber),
              _buildInfoRow('Город', freelancer.city),
              _buildInfoRow('Статус', freelancer.status),

              const SizedBox(height: 20),

              // Specializations
              const Text(
                'Специализации:',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF353F49),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: freelancer.specializationsWithLevels
                    .map(
                      (spec) => Chip(
                        label: Text(
                          '${_getSpecializationDisplayName(spec.specialization)} (${_getSkillLevelDisplayName(spec.skillLevel)})',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: const Color(0xFFF0F0F0),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF51B24F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Закрыть'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD9D9D9),
      ),
      child: Center(
        child: Text(
          freelancer.fullName.characters.first.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF96A4B3),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF96A4B3),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF353F49),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSpecializationDisplayName(String key) {
    // Use centralized specialization mappings
    return SpecializationConstants.getDisplayNameFromKey(key);
  }

  String _getSkillLevelDisplayName(String? level) {
    switch (level?.toLowerCase()) {
      case 'junior':
        return 'Младший';
      case 'middle':
        return 'Средний';
      case 'senior':
        return 'Продвинутый';
      default:
        return '';
    }
  }
}

// Occupied Specialization Card for showing occupied positions with freelancer info
class _OccupiedSpecializationCard extends StatelessWidget {
  final FreelancerModel freelancer;
  final AdminOrderSpecializationModel specialization;
  final VoidCallback? onTap;

  const _OccupiedSpecializationCard({
    required this.freelancer,
    required this.specialization,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final skillLevel = specialization.skillLevel?.toLowerCase() ?? 'junior';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 195,
        height: 176,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(
            76,
            175,
            80,
            0.1,
          ), // Green tint for occupied
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar with occupied indicator
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: ClipOval(
                    child:
                        freelancer.avatarUrl != null &&
                            freelancer.avatarUrl!.isNotEmpty
                        ? Image.network(
                            freelancer.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildAvatarFallback(),
                          )
                        : _buildAvatarFallback(),
                  ),
                ),
                // Occupied indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Text content
            Column(
              children: [
                Text(
                  freelancer.fullName,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.69,
                    color: Color(0xFF353F49),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _getSpecializationDisplayName(
                    specialization.specialization ?? '',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    color: Color(0xFF96A4B3),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Назначен',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 11.12,
                    color: Color(0xFF4CAF50),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Skill level badge positioned at bottom right
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 1, 6, 2),
                  decoration: BoxDecoration(
                    color: _getSkillLevelColor(skillLevel),
                    borderRadius: BorderRadius.circular(29),
                  ),
                  child: Text(
                    _getSkillLevelLabel(skillLevel),
                    style: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD9D9D9),
      ),
      child: Center(
        child: Text(
          freelancer.name.characters.first.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF96A4B3),
          ),
        ),
      ),
    );
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'junior':
        return const Color(0xFF51B24F);
      case 'middle':
        return const Color(0xFF2782E3);
      case 'senior':
        return const Color(0xFFFB984D);
      default:
        return const Color(0xFF51B24F);
    }
  }

  String _getSkillLevelLabel(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'junior':
        return 'JUN';
      case 'middle':
        return 'MID';
      case 'senior':
        return 'SEN';
      default:
        return 'JUN';
    }
  }

  String _getSpecializationDisplayName(String key) {
    // Use centralized specialization mappings
    return SpecializationConstants.getDisplayNameFromKey(key);
  }
}

class _OrderApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final FreelancerModel? freelancer;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _OrderApplicationCard({
    required this.application,
    this.freelancer,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (freelancer == null) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCADDE1)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCADDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: ClipOval(
                  child:
                      freelancer!.avatarUrl != null &&
                          freelancer!.avatarUrl!.isNotEmpty
                      ? Image.network(
                          freelancer!.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildAvatarFallback(freelancer!.name),
                        )
                      : _buildAvatarFallback(freelancer!.name),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freelancer!.fullName,
                      style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF353F49),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      freelancer!.specializationWithLevel,
                      style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 14,
                        color: Color(0xFF96A4B3),
                      ),
                    ),
                    if (application.specializationName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          'Заявка на позицию: ${application.specializationName}',
                          style: const TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF517499),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF51B24F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Принять'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935),
                        side: const BorderSide(color: Color(0xFFE53935)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Отказать'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (freelancer!.bio != null && freelancer!.bio!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'О себе',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF353F49),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              freelancer!.bio!,
              style: const TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF5D6B78),
              ),
            ),
          ],
          if (freelancer!.phoneNumber.isNotEmpty ||
              freelancer!.email.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (freelancer!.phoneNumber.isNotEmpty) ...[
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: Color(0xFF96A4B3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    freelancer!.phoneNumber,
                    style: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 14,
                      color: Color(0xFF5D6B78),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
                if (freelancer!.email.isNotEmpty) ...[
                  const Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Color(0xFF96A4B3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    freelancer!.email,
                    style: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 14,
                      color: Color(0xFF5D6B78),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD9D9D9),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
          style: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF96A4B3),
          ),
        ),
      ),
    );
  }
}
