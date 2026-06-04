import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../api/auth_api.dart';
import '../services/admin_session.dart';
import '../state/auth.dart';
import '../../core/navigation/app_router.dart';

class AdminAuthGuard {
  final AuthApi _authApi;
  final AuthStore _authStore;
  final AdminSession _adminSession;

  const AdminAuthGuard(
    this._authApi,
    this._authStore,
    this._adminSession,
  );

  Future<String?> checkAdminAuth(GoRouterState state) async {
    if (!kIsWeb) {
      return '/';
    }

    final path = state.uri.path;

    if (path == AppRouter.adminLoginRoute) {
      return null;
    }

    final accessToken = await _authStore.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      _adminSession.clear();
      return _loginRedirect(state);
    }

    if (_adminSession.isAuthenticated) {
      return null;
    }

    try {
      final isAdmin = await _authApi.isCurrentUserAdmin();
      if (isAdmin) {
        _adminSession.markAuthenticated();
        return null;
      }

      _adminSession.clear();
      return _loginRedirect(state);
    } catch (_) {
      // Keep session on transient network errors if we were verified before
      if (_adminSession.isAuthenticated) {
        return null;
      }

      return _loginRedirect(state);
    }
  }

  String _loginRedirect(GoRouterState state) {
    final location = state.uri.toString();
    return '${AppRouter.adminLoginRoute}?redirect=${Uri.encodeComponent(location)}';
  }
}
