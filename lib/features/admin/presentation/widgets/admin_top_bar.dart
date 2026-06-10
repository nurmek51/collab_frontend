import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../shared/api/auth_api.dart';

enum AdminTopNavSection { projects, freelancers }

class AdminTopBar extends StatelessWidget {
  final String displayName;
  final AdminTopNavSection activeSection;
  final AuthApi authApi;

  const AdminTopBar({
    super.key,
    required this.displayName,
    required this.activeSection,
    required this.authApi,
  });

  @override
  Widget build(BuildContext context) {
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
                GestureDetector(
                  onTap: () => context.go(AppRouter.adminRoute),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Image.asset(
                      'assets/images/collab_logo.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                _AdminTopNavItem(
                  label: 'Проекты',
                  active: activeSection == AdminTopNavSection.projects,
                  onTap: activeSection == AdminTopNavSection.projects
                      ? null
                      : () => context.go(AppRouter.adminRoute),
                ),
                const SizedBox(width: 12),
                _AdminTopNavItem(
                  label: 'Исполнители',
                  active: activeSection == AdminTopNavSection.freelancers,
                  onTap: activeSection == AdminTopNavSection.freelancers
                      ? null
                      : () => context.go(AppRouter.adminFreelancersRoute),
                ),
                const Spacer(),
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
                    await authApi.logout();
                    if (context.mounted) {
                      context.go(AppRouter.adminLoginRoute);
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
          ),
        ),
      ),
    );
  }
}

class _AdminTopNavItem extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _AdminTopNavItem({
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  State<_AdminTopNavItem> createState() => _AdminTopNavItemState();
}

class _AdminTopNavItemState extends State<_AdminTopNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;
    final backgroundColor = widget.active
        ? AppColors.adminAccentBlue.withValues(alpha: 0.1)
        : _hovered
        ? AppColors.adminAccentBlue.withValues(alpha: 0.08)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: isInteractive || !widget.active
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: widget.active ? FontWeight.w600 : FontWeight.w500,
              fontSize: 16,
              color: widget.active || _hovered
                  ? AppColors.adminPrimaryText
                  : AppColors.adminSecondaryText,
              decoration: _hovered && isInteractive
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: AppColors.adminAccentBlue,
            ),
          ),
        ),
      ),
    );
  }
}
