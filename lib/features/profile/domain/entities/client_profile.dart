/// Client Profile entity representing user profile data
class ClientProfile {
  final String id;
  final String name;
  final String surname;
  final String phoneNumber;

  const ClientProfile({
    required this.id,
    required this.name,
    required this.surname,
    required this.phoneNumber,
  });

  /// Get full name
  String get fullName => '$name $surname';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientProfile &&
        other.id == id &&
        other.name == name &&
        other.surname == surname &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        surname.hashCode ^
        phoneNumber.hashCode;
  }

  /// Create a copy with updated fields
  ClientProfile copyWith({
    String? id,
    String? name,
    String? surname,
    String? phoneNumber,
  }) {
    return ClientProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
