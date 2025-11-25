import '../../domain/entities/freelancer_profile.dart';
import '../../../../shared/state/freelancer_onboarding_state.dart';

/// Freelancer Profile model for data layer
class FreelancerProfileModel extends FreelancerProfile {
  const FreelancerProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.surname,
    required super.iin,
    required super.city,
    required super.specializationsWithLevels,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.email,
    super.portfolioLinks,
    super.socialLinks,
  });

  /// Create FreelancerProfileModel from JSON
  factory FreelancerProfileModel.fromJson(Map<String, dynamic> json) {
    return FreelancerProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      iin: json['iin'] as String,
      city: json['city'] as String,
      specializationsWithLevels:
          (json['specializations_with_levels'] as List<dynamic>)
              .map(
                (spec) => SpecializationWithLevel.fromJson(
                  spec as Map<String, dynamic>,
                ),
              )
              .toList(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      email: json['email'] as String?,
      portfolioLinks: json['portfolio_links'] != null
          ? Map<String, String>.from(json['portfolio_links'] as Map)
          : null,
      socialLinks: json['social_links'] != null
          ? Map<String, String>.from(json['social_links'] as Map)
          : null,
    );
  }

  /// Convert FreelancerProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'surname': surname,
      'iin': iin,
      'city': city,
      'specializations_with_levels': specializationsWithLevels
          .map((spec) => spec.toStorageJson())
          .toList(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (email != null) 'email': email,
      if (portfolioLinks != null) 'portfolio_links': portfolioLinks,
      if (socialLinks != null) 'social_links': socialLinks,
    };
  }

  /// Create FreelancerProfileModel from FreelancerProfile entity
  factory FreelancerProfileModel.fromEntity(FreelancerProfile profile) {
    return FreelancerProfileModel(
      id: profile.id,
      userId: profile.userId,
      name: profile.name,
      surname: profile.surname,
      iin: profile.iin,
      city: profile.city,
      specializationsWithLevels: profile.specializationsWithLevels,
      status: profile.status,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      email: profile.email,
      portfolioLinks: profile.portfolioLinks,
      socialLinks: profile.socialLinks,
    );
  }
}

/// Model for freelancer onboarding request
class FreelancerOnboardingRequest {
  final String name;
  final String surname;
  final String iin;
  final String city;
  final List<SpecializationWithLevel> specializationsWithLevels;
  final String? email;
  final Map<String, String>? socialLinks;
  final List<String>? portfolioLinks;

  const FreelancerOnboardingRequest({
    required this.name,
    required this.surname,
    required this.iin,
    required this.city,
    required this.specializationsWithLevels,
    this.email,
    this.socialLinks,
    this.portfolioLinks,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'iin': iin,
      'city': city,
      'specializations_with_levels': specializationsWithLevels
          .map((spec) => spec.toJson())
          .toList(),
      if (email != null) 'email': email,
      if (socialLinks != null) 'social_links': socialLinks,
      if (portfolioLinks != null) 'portfolio_links': portfolioLinks,
    };
  }

  bool get isValid {
    return name.isNotEmpty &&
        surname.isNotEmpty &&
        iin.isNotEmpty &&
        city.isNotEmpty &&
        specializationsWithLevels.isNotEmpty;
  }
}
