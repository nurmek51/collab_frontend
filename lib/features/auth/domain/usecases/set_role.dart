import '../repositories/auth_repository.dart';

/// Use case for setting user role after authentication
class SetRole {
  final AuthRepository _repository;

  SetRole(this._repository);

  /// Set user role
  Future<void> call(String role) async {
    if (role.isEmpty) {
      throw Exception('Role cannot be empty');
    }

    // Validate role
    const validRoles = ['client', 'freelancer'];
    if (!validRoles.contains(role)) {
      throw Exception('Invalid role: $role');
    }

    await _repository.switchRole(role);
  }
}
