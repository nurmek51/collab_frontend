import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../api/auth_api.dart';
import '../../core/navigation/app_router.dart';

class AdminAuthGuard {
  final AuthApi _authApi;

  const AdminAuthGuard(this._authApi);

  Future<String?> checkAdminAuth(GoRouterState state) async {
    // Admin routes only work on web
    if (!kIsWeb) {
      return '/';
    }

    final location = state.uri.toString();

    // Skip auth check for admin login page
    if (location == AppRouter.adminLoginRoute) {
      return null;
    }

    try {
      final user = await _authApi.getCurrentUser();
      if (user.isEmpty) {
        return '${AppRouter.adminLoginRoute}?redirect=${Uri.encodeComponent(location)}';
      }
      return null;
    } catch (e) {
      // For development: allow access when backend is down
      if (kDebugMode) {
        return null; // Allow access in debug mode
      }
      return '${AppRouter.adminLoginRoute}?redirect=${Uri.encodeComponent(location)}';
    }
  }
}
