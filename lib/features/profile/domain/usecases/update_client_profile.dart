import '../entities/client_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating client profile
class UpdateClientProfile {
  final ProfileRepository repository;

  UpdateClientProfile(this.repository);

  Future<ClientProfile> call({
    required String name,
    required String surname,
    required String phoneNumber,
  }) async {
    return await repository.updateClientProfile(
      name: name,
      surname: surname,
      phoneNumber: phoneNumber,
    );
  }
}
