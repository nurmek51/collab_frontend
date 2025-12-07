import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../auth/presentation/widgets/exit_confirm_modal.dart';

/// Profile popup menu widget displayed when tapping on profile icon
/// Shows "My Profile" and "Log out" options
class ProfilePopupMenu extends StatelessWidget {
  final VoidCallback onDismiss;
  final BuildContext parentContext;

  const ProfilePopupMenu({
    super.key,
    required this.onDismiss,
    required this.parentContext,
  });

  void _handleProfileTap(BuildContext context) {
    onDismiss();
    parentContext.push('/client-profile');
  }

  Future<void> _handleLogoutTap(BuildContext context) async {
    onDismiss();

    // Use post frame callback to ensure overlay is fully removed before showing dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (parentContext.mounted) {
        showDialog<bool>(
          context: parentContext,
          barrierColor: Colors.black.withValues(alpha: 0.4),
          builder: (context) => const ExitConfirmModal(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            spreadRadius: -5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 28.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My Profile option
          GestureDetector(
            onTap: () => _handleProfileTap(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Мой профиль',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 17.sp,
                    height: 1.3,
                    color: Colors.black.withValues(alpha: 0.87),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          // Log out option
          GestureDetector(
            onTap: () => _handleLogoutTap(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Выход',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 17.sp,
                    height: 1.3,
                    color: const Color(0xFFD54444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the profile popup menu as an overlay
void showProfilePopupMenu(BuildContext context, GlobalKey iconKey) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  // Store the parent context to use for navigation and dialogs
  final parentContext = context;

  // Get the position of the profile icon
  final RenderBox? renderBox =
      iconKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final iconPosition = renderBox.localToGlobal(Offset.zero);
  final iconSize = renderBox.size;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          // Transparent barrier to dismiss popup when tapping outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () => overlayEntry.remove(),
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Popup menu positioned below the icon, aligned to the right
          Positioned(
            top: iconPosition.dy + iconSize.height + 8.h,
            right: 20.w,
            child: Material(
              color: Colors.transparent,
              child: ProfilePopupMenu(
                onDismiss: () => overlayEntry.remove(),
                parentContext: parentContext,
              ),
            ),
          ),
        ],
      );
    },
  );

  overlay.insert(overlayEntry);
}
