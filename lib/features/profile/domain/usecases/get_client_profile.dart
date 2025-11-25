import '../entities/client_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for getting client profile
class GetClientProfile {
  final ProfileRepository repository;

  GetClientProfile(this.repository);

  Future<ClientProfile> call(String clientId) async {
    return await repository.getClientProfile(clientId);
  }
}
