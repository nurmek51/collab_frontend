import '../../../auth/domain/entities/user.dart';

/// User model for data layer
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firebaseUid,
    required super.phoneNumber,
    required super.availableRoles,
    required super.currentRole,
    required super.status,
    required super.createdAt,
    required super.lastLogin,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firebaseUid: json['firebase_uid'] as String,
      phoneNumber: json['phone_number'] as String,
      availableRoles: (json['available_roles'] as List<dynamic>).cast<String>(),
      currentRole: json['current_role'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: DateTime.parse(json['last_login'] as String),
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'phone_number': phoneNumber,
      'available_roles': availableRoles,
      'current_role': currentRole,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
    };
  }

  /// Create UserModel from User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      firebaseUid: user.firebaseUid,
      phoneNumber: user.phoneNumber,
      availableRoles: user.availableRoles,
      currentRole: user.currentRole,
      status: user.status,
      createdAt: user.createdAt,
      lastLogin: user.lastLogin,
    );
  }
}
