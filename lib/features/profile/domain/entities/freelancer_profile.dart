import '../../../../shared/state/freelancer_onboarding_state.dart';

/// Freelancer Profile entity
class FreelancerProfile {
  final String id;
  final String userId;
  final String name;
  final String surname;
  final String iin;
  final String city;
  final List<SpecializationWithLevel> specializationsWithLevels;
  final String status; // incomplete, pending, approved, rejected
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? email;
  final Map<String, String>? portfolioLinks;
  final Map<String, String>? socialLinks;

  const FreelancerProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.surname,
    required this.iin,
    required this.city,
    required this.specializationsWithLevels,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.portfolioLinks,
    this.socialLinks,
  });

  /// Get full name
  String get fullName => '$name $surname';

  /// Check if profile is complete
  bool get isComplete => status != 'incomplete';

  /// Check if profile is approved
  bool get isApproved => status == 'approved';

  /// Get specializations as simple list
  List<String> get specializations {
    return specializationsWithLevels
        .map((spec) => spec.specialization)
        .toList();
  }

  /// Get skill levels as simple list
  List<String> get skillLevels {
    return specializationsWithLevels
        .map((spec) => spec.skillLevel ?? 'junior')
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FreelancerProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FreelancerProfile(id: $id, name: $fullName, status: $status)';
  }
}
