import '../entities/client_profile.dart';
import '../repositories/profile_repository.dart';

/// Parameters for updating client profile
class UpdateClientProfileParams {
  final String name;
  final String surname;
  final String phoneNumber;

  const UpdateClientProfileParams({
    required this.name,
    required this.surname,
    required this.phoneNumber,
  });
}

/// Use case for updating client profile
class UpdateClientProfile {
  final ProfileRepository _repository;

  UpdateClientProfile(this._repository);

  /// Update client profile
  Future<ClientProfile> call(UpdateClientProfileParams params) async {
    // Basic validation
    if (params.name.trim().isEmpty) {
      throw Exception('Name cannot be empty');
    }

    if (params.surname.trim().isEmpty) {
      throw Exception('Surname cannot be empty');
    }

    if (params.phoneNumber.trim().isEmpty) {
      throw Exception('Phone number cannot be empty');
    }

    return await _repository.updateClientProfile(
      name: params.name,
      surname: params.surname,
      phoneNumber: params.phoneNumber,
    );
  }
}
