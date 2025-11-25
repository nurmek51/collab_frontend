import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../state/auth.dart';
import '../services/freelancer_profile_status_manager.dart';

/// Guard that redirects to auth if token is missing
class AuthGuard {
  final AuthStore _authStore;

  AuthGuard(this._authStore);

  /// Check if user is authenticated and redirect if not
  Future<String?> checkAuth(BuildContext context, GoRouterState state) async {
    final isAuthenticated = await _authStore.isAuthenticated();

    if (!isAuthenticated) {
      // Redirect to welcome page if not authenticated
      return '/';
    }

    return null; // Allow access
  }
}

/// Guard that routes based on user role
class RoleGuard {
  final AuthStore _authStore;
  final FreelancerProfileStatusManager _statusManager;

  RoleGuard(this._authStore, this._statusManager);

  /// Route to appropriate flow based on role
  Future<String?> checkRole(BuildContext context, GoRouterState state) async {
    final role = await _authStore.getRole();

    if (role == null) {
      // No role set, redirect to role selection
      return '/select-role';
    }

    // Role-specific routing logic can be added here
    return null; // Allow access
  }

  /// Get initial route based on user role
  Future<String> getInitialRoute() async {
    final isAuthenticated = await _authStore.isAuthenticated();

    if (!isAuthenticated) {
      return '/';
    }

    final role = await _authStore.getRole();

    switch (role) {
      case 'client':
        return '/my-orders'; // Client dashboard
      case 'freelancer':
        // Use FreelancerProfileStatusManager to get appropriate route
        final redirectRoute = await _statusManager.getRedirectRoute();
        return redirectRoute ?? '/my-work'; // Fallback to my-work if null
      default:
        return '/select-role'; // Role selection if no role
    }
  }
}

/// Mixin for pages that require authentication
mixin AuthRequiredMixin<T extends StatefulWidget> on State<T> {
  late AuthStore _authStore;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authStore = AuthStore(); // In real app, get from DI
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await _authStore.isAuthenticated();

    if (!isAuthenticated && mounted) {
      // Redirect to welcome page
      context.go('/');
      return;
    }

    setState(() {
      _isAuthenticated = isAuthenticated;
    });
  }

  /// Override this to provide loading widget
  Widget buildLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  /// Override this to provide the authenticated content
  Widget buildAuthenticated();

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return buildLoading();
    }

    return buildAuthenticated();
  }
}

/// Mixin for pages that require specific role
mixin RoleRequiredMixin<T extends StatefulWidget> on State<T> {
  late AuthStore _authStore;
  String? _userRole;
  bool _isLoading = true;

  /// Override this to specify required role
  String get requiredRole;

  @override
  void initState() {
    super.initState();
    _authStore = AuthStore(); // In real app, get from DI
    _checkRole();
  }

  Future<void> _checkRole() async {
    final isAuthenticated = await _authStore.isAuthenticated();

    if (!isAuthenticated && mounted) {
      context.go('/');
      return;
    }

    final role = await _authStore.getRole();

    if (role != requiredRole && mounted) {
      // Redirect based on actual role or to role selection
      if (role == null) {
        context.go('/select-role');
      } else {
        // Redirect to appropriate dashboard
        final roleGuard = RoleGuard(
          _authStore,
          GetIt.instance<FreelancerProfileStatusManager>(),
        );
        final route = await roleGuard.getInitialRoute();
        context.go(route);
      }
      return;
    }

    if (mounted) {
      setState(() {
        _userRole = role;
        _isLoading = false;
      });
    }
  }

  /// Override this to provide loading widget
  Widget buildLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  /// Override this to provide the role-specific content
  Widget buildRoleContent();

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _userRole != requiredRole) {
      return buildLoading();
    }

    return buildRoleContent();
  }
}
