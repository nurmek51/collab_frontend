import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/api/admin_api.dart';
import '../../../../shared/api/auth_api.dart';
import '../../../../shared/api/client.dart';
import '../../../../features/orders/data/models/freelancer_model.dart';

class AdminFreelancersPage extends StatefulWidget {
  const AdminFreelancersPage({super.key});

  @override
  State<AdminFreelancersPage> createState() => _AdminFreelancersPageState();
}

class _AdminFreelancersPageState extends State<AdminFreelancersPage> {
  late final AuthApi _authApi;
  late final AdminApi _adminApi;
  List<FreelancerModel> _freelancers = const [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  String? _userDisplayName;

  // Action state
  final Map<String, bool> _processingActions = {};

  @override
  void initState() {
    super.initState();
    _authApi = sl<AuthApi>();
    _adminApi = sl<AdminApi>();
    _loadUser();
    _loadFreelancers();
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

      if ((error is ApiException && error.statusCode == 403) ||
          error.toString().contains('403') ||
          error.toString().contains('Unauthorized') ||
          error.toString().contains('unauthorized')) {
        context.go('/admin/login');
        return;
      }

      setState(() {
        _userDisplayName = 'Администратор';
      });
    }
  }

  Future<void> _loadFreelancers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _adminApi.getPendingFreelancers();
      if (!mounted) {
        return;
      }

      // The API client already unwraps the envelope, so response IS the data object
      // containing 'items', 'total', 'page', 'size', 'pages'
      final items = response['items'] as List<dynamic>? ?? [];

      final freelancers = items
          .map((item) => FreelancerModel.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _freelancers = freelancers;
        _isLoading = false;
        if (_selectedIndex >= freelancers.length) {
          _selectedIndex = freelancers.isEmpty ? 0 : freelancers.length - 1;
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      if ((error is ApiException && error.statusCode == 403) ||
          error.toString().contains('403') ||
          error.toString().contains('Unauthorized') ||
          error.toString().contains('unauthorized')) {
        context.go('/admin/login');
        return;
      }

      setState(() {
        _errorMessage = error.toString();
        _freelancers = const [];
        _isLoading = false;
      });
    }
  }

  void _selectFreelancer(int index) {
    if (_freelancers.isEmpty) {
      return;
    }
    if (index < 0 || index >= _freelancers.length) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _approveFreelancer(String freelancerId) async {
    if (_processingActions[freelancerId] == true) return;

    setState(() {
      _processingActions[freelancerId] = true;
    });

    try {
      await _adminApi.updateFreelancerStatus(
        freelancerId: freelancerId,
        status: 'approved',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фрилансер успешно одобрен'),
          backgroundColor: Colors.green,
        ),
      );

      // Remove from list and reload
      await _loadFreelancers();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _processingActions[freelancerId] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $error'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectFreelancer(String freelancerId) async {
    if (_processingActions[freelancerId] == true) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отклонить фрилансера?'),
        content: const Text(
          'Вы уверены, что хотите отклонить заявку этого фрилансера?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Отклонить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _processingActions[freelancerId] = true;
    });

    try {
      await _adminApi.updateFreelancerStatus(
        freelancerId: freelancerId,
        status: 'rejected',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фрилансер отклонен'),
          backgroundColor: Colors.orange,
        ),
      );

      // Remove from list and reload
      await _loadFreelancers();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _processingActions[freelancerId] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $error'), backgroundColor: Colors.red),
      );
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
                GestureDetector(
                  onTap: () => context.go(AppRouter.adminRoute),
                  child: _buildTopNavItem('Проекты', active: false),
                ),
                const SizedBox(width: 24),
                _buildTopNavItem('Заказчики'),
                const SizedBox(width: 24),
                _buildTopNavItem('Исполнители', active: true),
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
                          context.go('/admin/login');
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
    return Container(
      height: 52,
      color: AppColors.black,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                _AdminFilterChip(
                  filter: _AdminFilter(
                    label: 'Ожидают проверки',
                    count: _freelancers.length,
                    active: true,
                    filterKey: 'pending',
                  ),
                  onTap: null,
                ),
              ],
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
              'Заявки фрилансеров',
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
                  : _freelancers.isEmpty
                  ? _buildSidebarEmpty()
                  : ListView.separated(
                      itemCount: _freelancers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final freelancer = _freelancers[index];
                        final selected = index == _selectedIndex;
                        return _FreelancerSidebarItem(
                          freelancer: freelancer,
                          selected: selected,
                          onTap: () => _selectFreelancer(index),
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
            onPressed: _loadFreelancers,
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
        'Нет заявок на проверку',
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
    if (_freelancers.isEmpty) {
      return Center(
        child: Text(
          'Выберите фрилансера для просмотра',
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.adminSecondaryText,
          ),
        ),
      );
    }

    final freelancer = _freelancers[_selectedIndex];
    final isProcessing = _processingActions[freelancer.freelancerId] ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and avatar
          _buildFreelancerHeader(freelancer),
          const SizedBox(height: 32),

          // Info cards in a row
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildContactInfoCard(freelancer)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildSpecializationsCard(freelancer)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildContactInfoCard(freelancer),
                  const SizedBox(height: 24),
                  _buildSpecializationsCard(freelancer),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Bio card
          if (freelancer.bio != null && freelancer.bio!.isNotEmpty)
            _buildBioCard(freelancer),
          if (freelancer.bio != null && freelancer.bio!.isNotEmpty)
            const SizedBox(height: 24),

          // Social and Portfolio links
          LayoutBuilder(
            builder: (context, constraints) {
              final hasSocial = freelancer.socialLinks?.isNotEmpty == true;
              final hasPortfolio =
                  freelancer.portfolioLinks?.isNotEmpty == true;

              if (!hasSocial && !hasPortfolio) {
                return const SizedBox.shrink();
              }

              if (constraints.maxWidth > 900 && hasSocial && hasPortfolio) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasSocial)
                      Expanded(child: _buildSocialLinksCard(freelancer)),
                    if (hasSocial && hasPortfolio) const SizedBox(width: 24),
                    if (hasPortfolio)
                      Expanded(child: _buildPortfolioLinksCard(freelancer)),
                  ],
                );
              }

              return Column(
                children: [
                  if (hasSocial) _buildSocialLinksCard(freelancer),
                  if (hasSocial && hasPortfolio) const SizedBox(height: 24),
                  if (hasPortfolio) _buildPortfolioLinksCard(freelancer),
                ],
              );
            },
          ),
          const SizedBox(height: 40),

          // Action buttons
          _buildActionButtons(freelancer, isProcessing),
        ],
      ),
    );
  }

  Widget _buildFreelancerHeader(FreelancerModel freelancer) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: ClipOval(
            child:
                freelancer.avatarUrl != null && freelancer.avatarUrl!.isNotEmpty
                ? Image.network(
                    freelancer.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildAvatarFallback(freelancer.fullName),
                  )
                : _buildAvatarFallback(freelancer.fullName),
          ),
        ),
        const SizedBox(width: 24),
        // Name and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                freelancer.fullName,
                style: const TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: AppColors.adminPrimaryText,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.adminAccentOrange.withAlpha(31),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(freelancer.status),
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.adminAccentOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initials = name.split(' ').take(2).map((e) {
      if (e.isEmpty) return '';
      return e.characters.first.toUpperCase();
    }).join();

    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD9D9D9),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 32,
            color: Color(0xFF96A4B3),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(FreelancerModel freelancer) {
    return _AdminCard(
      title: 'Контактная информация',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Email', freelancer.email),
          const SizedBox(height: 12),
          _buildInfoRow('Телефон', freelancer.phoneNumber),
          const SizedBox(height: 12),
          _buildInfoRow('Город', freelancer.city),
          const SizedBox(height: 12),
          _buildInfoRow('ИИН', freelancer.iin),
        ],
      ),
    );
  }

  Widget _buildSpecializationsCard(FreelancerModel freelancer) {
    return _AdminCard(
      title: 'Специализации',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: freelancer.specializationsWithLevels.map((spec) {
          final displayName = SpecializationConstants.getDisplayNameFromKey(
            spec.specialization,
          );
          final level = _getSkillLevelLabel(spec.skillLevel);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getSkillLevelColor(spec.skillLevel).withAlpha(31),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getSkillLevelColor(spec.skillLevel).withAlpha(77),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.adminPrimaryText,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getSkillLevelColor(spec.skillLevel),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBioCard(FreelancerModel freelancer) {
    return _AdminCard(
      title: 'О себе',
      child: Text(
        freelancer.bio ?? '',
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: AppColors.adminPrimaryText,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSocialLinksCard(FreelancerModel freelancer) {
    final links = freelancer.socialLinks ?? {};
    if (links.isEmpty) return const SizedBox.shrink();

    return _AdminCard(
      title: 'Социальные сети',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: links.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildInfoRow(entry.key, entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPortfolioLinksCard(FreelancerModel freelancer) {
    final links = freelancer.portfolioLinks ?? {};
    if (links.isEmpty) return const SizedBox.shrink();

    return _AdminCard(
      title: 'Портфолио',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: links.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildInfoRow(entry.key, entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.adminSecondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.adminPrimaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(FreelancerModel freelancer, bool isProcessing) {
    return Row(
      children: [
        // Approve button
        Expanded(
          child: ElevatedButton(
            onPressed: isProcessing
                ? null
                : () => _approveFreelancer(freelancer.freelancerId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminAccentGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.adminAccentGreen.withAlpha(
                128,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Одобрить'),
          ),
        ),
        const SizedBox(width: 16),
        // Reject button
        Expanded(
          child: OutlinedButton(
            onPressed: isProcessing
                ? null
                : () => _rejectFreelancer(freelancer.freelancerId),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Отклонить'),
          ),
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Ожидает проверки';
      case 'approved':
        return 'Одобрен';
      case 'rejected':
        return 'Отклонен';
      default:
        return status;
    }
  }

  Color _getSkillLevelColor(String? skillLevel) {
    switch (skillLevel?.toLowerCase()) {
      case 'junior':
        return const Color(0xFF22C55E);
      case 'middle':
        return const Color(0xFF3B82F6);
      case 'senior':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getSkillLevelLabel(String? skillLevel) {
    switch (skillLevel?.toLowerCase()) {
      case 'junior':
        return 'Junior';
      case 'middle':
        return 'Middle';
      case 'senior':
        return 'Senior';
      default:
        return skillLevel ?? 'N/A';
    }
  }
}

// Reusable filter chip widget
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

// Sidebar item for freelancer
class _FreelancerSidebarItem extends StatelessWidget {
  final FreelancerModel freelancer;
  final bool selected;
  final VoidCallback onTap;

  const _FreelancerSidebarItem({
    required this.freelancer,
    required this.selected,
    required this.onTap,
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
          child: Row(
            children: [
              // Small avatar
              Container(
                width: 44,
                height: 44,
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
                              _buildSmallAvatarFallback(freelancer.fullName),
                        )
                      : _buildSmallAvatarFallback(freelancer.fullName),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freelancer.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.adminPrimaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      freelancer.primarySpecialization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: AppColors.adminSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFD9D9D9),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF96A4B3),
          ),
        ),
      ),
    );
  }
}

// Reusable admin card widget
class _AdminCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _AdminCard({required this.title, required this.child});

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
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: AppColors.adminPrimaryText,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
