import '../entities/client_profile.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  /// Get client profile by client ID
  Future<ClientProfile> getClientProfile(String clientId);

  /// Update client profile
  Future<ClientProfile> updateClientProfile({
    required String name,
    required String surname,
    required String phoneNumber,
  });
}
