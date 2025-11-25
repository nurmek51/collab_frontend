/// Specialization offer conditions
class SpecializationConditions {
  final double salary;
  final String payPer;
  final int requiredExperience;
  final String scheduleType;
  final String formatType;

  const SpecializationConditions({
    required this.salary,
    required this.payPer,
    required this.requiredExperience,
    required this.scheduleType,
    required this.formatType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpecializationConditions &&
        other.salary == salary &&
        other.payPer == payPer &&
        other.requiredExperience == requiredExperience &&
        other.scheduleType == scheduleType &&
        other.formatType == formatType;
  }

  @override
  int get hashCode {
    return Object.hash(
      salary,
      payPer,
      requiredExperience,
      scheduleType,
      formatType,
    );
  }
}

/// Specialization offer entity with vacancy support
class SpecializationOffer {
  final String specialization;
  final String skillLevel;
  final SpecializationConditions conditions;
  final String requirements;
  final String? vacancyId;
  final bool isOccupied;
  final String? occupiedByFreelancerId;

  const SpecializationOffer({
    required this.specialization,
    required this.skillLevel,
    required this.conditions,
    required this.requirements,
    this.vacancyId,
    this.isOccupied = false,
    this.occupiedByFreelancerId,
  });

  /// Check if this specialization is available for application
  bool get isAvailable => !isOccupied;

  /// Create a copy with updated values
  SpecializationOffer copyWith({
    String? specialization,
    String? skillLevel,
    SpecializationConditions? conditions,
    String? requirements,
    String? vacancyId,
    bool? isOccupied,
    String? occupiedByFreelancerId,
  }) {
    return SpecializationOffer(
      specialization: specialization ?? this.specialization,
      skillLevel: skillLevel ?? this.skillLevel,
      conditions: conditions ?? this.conditions,
      requirements: requirements ?? this.requirements,
      vacancyId: vacancyId ?? this.vacancyId,
      isOccupied: isOccupied ?? this.isOccupied,
      occupiedByFreelancerId:
          occupiedByFreelancerId ?? this.occupiedByFreelancerId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpecializationOffer &&
        other.specialization == specialization &&
        other.skillLevel == skillLevel &&
        other.conditions == conditions &&
        other.requirements == requirements &&
        other.vacancyId == vacancyId &&
        other.isOccupied == isOccupied &&
        other.occupiedByFreelancerId == occupiedByFreelancerId;
  }

  @override
  int get hashCode {
    return Object.hash(
      specialization,
      skillLevel,
      conditions,
      requirements,
      vacancyId,
      isOccupied,
      occupiedByFreelancerId,
    );
  }
}
