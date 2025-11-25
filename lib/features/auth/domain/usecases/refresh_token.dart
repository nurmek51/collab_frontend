import '../repositories/auth_repository.dart';

/// Use case for refreshing authentication token
class RefreshToken {
  final AuthRepository _repository;

  RefreshToken(this._repository);

  /// Refresh authentication token
  Future<bool> call() async {
    return await _repository.refreshToken();
  }
}
