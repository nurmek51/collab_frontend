import '../entities/client_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for getting client profile
class GetProfile {
  final ProfileRepository _repository;

  GetProfile(this._repository);

  /// Get client profile by ID
  Future<ClientProfile> call(String clientId) async {
    return await _repository.getClientProfile(clientId);
  }
}
