import '../../domain/entities/team_member.dart';

/// Team member model for data layer
class TeamMemberModel extends TeamMember {
  const TeamMemberModel({
    required super.id,
    required super.name,
    required super.role,
    required super.rate,
    super.avatarUrl,
  });

  /// Create TeamMemberModel from JSON
  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      rate: json['rate']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  /// Convert TeamMemberModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'rate': rate,
      'avatar_url': avatarUrl,
    };
  }

  /// Create TeamMemberModel from TeamMember entity
  factory TeamMemberModel.fromEntity(TeamMember teamMember) {
    return TeamMemberModel(
      id: teamMember.id,
      name: teamMember.name,
      role: teamMember.role,
      rate: teamMember.rate,
      avatarUrl: teamMember.avatarUrl,
    );
  }
}
