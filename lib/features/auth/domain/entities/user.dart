/// User entity representing current authenticated user
class User {
  final String id;
  final String firebaseUid;
  final String phoneNumber;
  final List<String> availableRoles;
  final String currentRole;
  final String status;
  final DateTime createdAt;
  final DateTime lastLogin;

  const User({
    required this.id,
    required this.firebaseUid,
    required this.phoneNumber,
    required this.availableRoles,
    required this.currentRole,
    required this.status,
    required this.createdAt,
    required this.lastLogin,
  });

  /// Check if user has multiple roles
  bool get hasMultipleRoles => availableRoles.length > 1;

  /// Check if user is active
  bool get isActive => status == 'active';

  /// Check if user can switch to specific role
  bool canSwitchToRole(String role) => availableRoles.contains(role);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, phone: $phoneNumber, currentRole: $currentRole)';
  }
}
