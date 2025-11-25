import '../repositories/auth_repository.dart';

/// Use case for logging out user
class Logout {
  final AuthRepository _repository;

  Logout(this._repository);

  /// Logout user and clear all authentication data
  Future<void> call() async {
    await _repository.logout();
  }
}
