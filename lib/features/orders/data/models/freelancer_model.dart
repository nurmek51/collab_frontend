import 'package:collab_frontend/core/constants/specialization_constants.dart';

/// Freelancer model for displaying colleague information
class FreelancerModel {
  final String freelancerId;
  final String userId;
  final String iin;
  final String city;
  final String email;
  final List<SpecializationWithLevel> specializationsWithLevels;
  final String name;
  final String surname;
  final String phoneNumber;
  final String status;
  final Map<String, String>? paymentInfo;
  final Map<String, String>? socialLinks;
  final Map<String, String>? portfolioLinks;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FreelancerModel({
    required this.freelancerId,
    required this.userId,
    required this.iin,
    required this.city,
    required this.email,
    required this.specializationsWithLevels,
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.paymentInfo,
    this.socialLinks,
    this.portfolioLinks,
    this.avatarUrl,
    this.bio,
  });

  /// Get full name
  String get fullName => '$name $surname';

  /// Get primary specialization display name
  String get primarySpecialization {
    if (specializationsWithLevels.isEmpty) return 'Специалист';

    final spec = specializationsWithLevels.first;
    return _getSpecializationDisplayName(spec.specialization);
  }

  /// Get specialization with skill level
  String get specializationWithLevel {
    if (specializationsWithLevels.isEmpty) return 'Специалист';

    final spec = specializationsWithLevels.first;
    final displayName = _getSpecializationDisplayName(spec.specialization);
    final level = _getSkillLevelDisplayName(spec.skillLevel);

    return level.isNotEmpty ? '$level $displayName' : displayName;
  }

  String _getSpecializationDisplayName(String key) {
    // Use centralized specialization mappings
    return SpecializationConstants.getDisplayNameFromKey(key);
  }

  String _getSkillLevelDisplayName(String? level) {
    switch (level?.toLowerCase()) {
      case 'junior':
        return 'Младший';
      case 'middle':
        return 'Средний';
      case 'senior':
        return 'Продвинутый';
      default:
        return '';
    }
  }

  /// Create FreelancerModel from JSON
  factory FreelancerModel.fromJson(Map<String, dynamic> json) {
    return FreelancerModel(
      freelancerId: json['freelancer_id'] as String,
      userId: json['user_id'] as String,
      iin: json['iin'] as String,
      city: json['city'] as String,
      email: json['email'] as String,
      specializationsWithLevels:
          (json['specializations_with_levels'] as List<dynamic>)
              .map(
                (spec) => SpecializationWithLevel.fromJson(
                  spec as Map<String, dynamic>,
                ),
              )
              .toList(),
      name: json['name'] as String,
      surname: json['surname'] as String,
      phoneNumber: json['phone_number'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paymentInfo: json['payment_info'] != null
          ? Map<String, String>.from(json['payment_info'] as Map)
          : null,
      socialLinks: json['social_links'] != null
          ? Map<String, String>.from(json['social_links'] as Map)
          : null,
      portfolioLinks: json['portfolio_links'] != null
          ? Map<String, String>.from(json['portfolio_links'] as Map)
          : null,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
    );
  }

  /// Convert FreelancerModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'freelancer_id': freelancerId,
      'user_id': userId,
      'iin': iin,
      'city': city,
      'email': email,
      'specializations_with_levels': specializationsWithLevels
          .map((spec) => spec.toJson())
          .toList(),
      'name': name,
      'surname': surname,
      'phone_number': phoneNumber,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (paymentInfo != null) 'payment_info': paymentInfo,
      if (socialLinks != null) 'social_links': socialLinks,
      if (portfolioLinks != null) 'portfolio_links': portfolioLinks,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (bio != null) 'bio': bio,
    };
  }
}

/// Specialization with level class for freelancer
class SpecializationWithLevel {
  final String specialization;
  final String? skillLevel;

  const SpecializationWithLevel({
    required this.specialization,
    this.skillLevel,
  });

  factory SpecializationWithLevel.fromJson(Map<String, dynamic> json) {
    return SpecializationWithLevel(
      specialization: json['specialization'] as String,
      skillLevel: json['skill_level'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialization': specialization,
      if (skillLevel != null) 'skill_level': skillLevel,
    };
  }
}
