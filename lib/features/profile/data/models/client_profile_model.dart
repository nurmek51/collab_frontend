import '../../domain/entities/client_profile.dart';

/// Client Profile model for data layer
class ClientProfileModel extends ClientProfile {
  const ClientProfileModel({
    required super.id,
    required super.name,
    required super.surname,
    required super.phoneNumber,
  });

  /// Create ClientProfileModel from JSON
  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: json['client_id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      phoneNumber: json['phone_number'] as String,
    );
  }

  /// Convert ClientProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'client_id': id,
      'name': name,
      'surname': surname,
      'phone_number': phoneNumber,
    };
  }

  /// Create ClientProfileModel from ClientProfile entity
  factory ClientProfileModel.fromEntity(ClientProfile profile) {
    return ClientProfileModel(
      id: profile.id,
      name: profile.name,
      surname: profile.surname,
      phoneNumber: profile.phoneNumber,
    );
  }
}
