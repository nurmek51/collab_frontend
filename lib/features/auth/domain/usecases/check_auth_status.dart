import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for checking authentication status
class CheckAuthStatus {
  final AuthRepository _repository;

  CheckAuthStatus(this._repository);

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _repository.isAuthenticated();
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    return await _repository.getCurrentUserId();
  }

  /// Get current user role
  Future<String?> getCurrentUserRole() async {
    return await _repository.getCurrentUserRole();
  }

  /// Get current user information
  Future<User> getCurrentUser() async {
    return await _repository.getCurrentUser();
  }
}
