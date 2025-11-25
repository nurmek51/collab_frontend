import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_response.dart';
import '../../../../core/services/background_refresh_manager.dart';

/// Authentication Cubit with auto-refresh integration
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final BackgroundRefreshManager _backgroundRefresh;

  AuthCubit({
    required AuthRepository authRepository,
    BackgroundRefreshManager? backgroundRefreshManager,
  }) : _authRepository = authRepository,
       _backgroundRefresh =
           backgroundRefreshManager ?? BackgroundRefreshManager.instance,
       super(const AuthInitial());

  /// Initialize authentication state
  Future<void> initialize() async {
    emit(const AuthLoading());

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        final userId = await _authRepository.getCurrentUserId();
        final role = await _authRepository.getCurrentUserRole();

        if (userId != null) {
          // Start background refresh for authenticated users
          _backgroundRefresh.startOnLogin();

          if (role != null && role.isNotEmpty) {
            emit(AuthAuthenticated(userId: userId, currentRole: role));
          } else {
            emit(AuthRoleSelectionRequired(userId));
          }
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to initialize authentication: $e'));
    }
  }

  /// Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    emit(const AuthLoading());

    try {
      await _authRepository.sendOtp(phoneNumber);
      emit(AuthOtpSent(phoneNumber));
    } catch (e) {
      emit(AuthError('Failed to send OTP: $e'));
    }
  }

  /// Verify OTP and authenticate user
  Future<void> verifyOtp(String phoneNumber, String otp) async {
    emit(const AuthLoading());

    try {
      final authResponse = await _authRepository.verifyOtp(phoneNumber, otp);

      if (authResponse.isValid) {
        // Background refresh is automatically started by the ApiService
        // when tokens are saved during verifyOtp

        if (authResponse.currentRole != null &&
            authResponse.currentRole!.isNotEmpty) {
          emit(
            AuthAuthenticated(
              userId: authResponse.userId,
              currentRole: authResponse.currentRole,
            ),
          );
        } else {
          emit(AuthRoleSelectionRequired(authResponse.userId));
        }
      } else {
        emit(const AuthError('Invalid authentication response'));
      }
    } catch (e) {
      emit(AuthError('Failed to verify OTP: $e'));
    }
  }

  /// Set user role after authentication
  Future<void> setRole(String role) async {
    if (state is! AuthRoleSelectionRequired) {
      emit(const AuthError('Role selection not required in current state'));
      return;
    }

    final currentState = state as AuthRoleSelectionRequired;
    emit(const AuthLoading());

    try {
      await _authRepository.switchRole(role);

      emit(AuthAuthenticated(userId: currentState.userId, currentRole: role));
    } catch (e) {
      emit(AuthError('Failed to set role: $e'));
      // Restore previous state
      emit(currentState);
    }
  }

  /// Logout user
  Future<void> logout() async {
    emit(const AuthLoading());

    try {
      await _authRepository.logout();
      // Background refresh is automatically stopped by the ApiService
      emit(const AuthUnauthenticated());
    } catch (e) {
      // Even if logout request fails, clear local state
      emit(const AuthUnauthenticated());
    }
  }

  /// Manually refresh token (for debugging or recovery)
  Future<void> refreshToken() async {
    try {
      final success = await _authRepository.refreshToken();

      if (!success) {
        // If refresh fails, logout user
        emit(const AuthUnauthenticated());
      }
      // If refresh succeeds, keep current state
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    return await _authRepository.isAuthenticated();
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    return await _authRepository.getCurrentUserId();
  }

  /// Get current user role
  Future<String?> getCurrentUserRole() async {
    return await _authRepository.getCurrentUserRole();
  }

  /// Handle authentication errors from other parts of the app
  void handleAuthError(String error) {
    emit(AuthError(error));
  }

  /// Reset to initial state
  void reset() {
    emit(const AuthInitial());
  }
}
