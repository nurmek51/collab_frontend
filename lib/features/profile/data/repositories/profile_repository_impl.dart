import '../../../../core/services/api_service.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/client_profile_model.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService apiService;

  const ProfileRepositoryImpl(this.apiService);

  @override
  Future<ClientProfile> getClientProfile(String clientId) async {
    final response = await apiService.getClientProfile(clientId);
    return ClientProfileModel.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ClientProfile> updateClientProfile({
    required String name,
    required String surname,
    required String phoneNumber,
  }) async {
    final response = await apiService.updateClientProfile(
      name: name,
      surname: surname,
      phoneNumber: phoneNumber,
    );

    return ClientProfileModel.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }
}
