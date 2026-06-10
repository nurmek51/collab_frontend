/// Team member entity representing a project team member
class TeamMember {
  final String id;
  final String name;
  final String role;
  final String rate;
  final String? avatarUrl;
  final bool hasAvatar;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.rate,
    this.avatarUrl,
    this.hasAvatar = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamMember &&
        other.id == id &&
        other.name == name &&
        other.role == role &&
        other.rate == rate &&
        other.avatarUrl == avatarUrl &&
        other.hasAvatar == hasAvatar;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        role.hashCode ^
        rate.hashCode ^
        avatarUrl.hashCode ^
        hasAvatar.hashCode;
  }
}
