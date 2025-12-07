import '../../domain/entities/specialization_offer.dart';

/// Specialization conditions model for data layer
class SpecializationConditionsModel extends SpecializationConditions {
  const SpecializationConditionsModel({
    required super.salary,
    required super.payPer,
    required super.requiredExperience,
    required super.scheduleType,
    required super.formatType,
  });

  /// Create SpecializationConditionsModel from JSON
  factory SpecializationConditionsModel.fromJson(Map<String, dynamic> json) {
    return SpecializationConditionsModel(
      salary: json['salary'] is num ? (json['salary'] as num).toDouble() : 0.0,
      payPer: json['pay_per'] as String? ?? 'hour',
      requiredExperience: json['required_experience'] as int? ?? 0,
      scheduleType: json['schedule_type'] as String? ?? 'full-time',
      formatType: json['format_type'] as String? ?? 'remote',
    );
  }

  /// Convert SpecializationConditionsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'salary': salary,
      'pay_per': payPer,
      'required_experience': requiredExperience,
      'schedule_type': scheduleType,
      'format_type': formatType,
    };
  }
}

/// Specialization offer model for data layer with vacancy support
class SpecializationOfferModel extends SpecializationOffer {
  const SpecializationOfferModel({
    required super.specialization,
    required super.skillLevel,
    required super.conditions,
    required super.requirements,
    super.vacancyId,
    super.isOccupied = false,
    super.occupiedByFreelancerId,
  });

  /// Create SpecializationOfferModel from JSON
  factory SpecializationOfferModel.fromJson(Map<String, dynamic> json) {
    return SpecializationOfferModel(
      specialization: json['specialization'] as String? ?? '',
      skillLevel: json['skill_level'] as String? ?? '',
      conditions:
          json['conditions'] != null &&
              json['conditions'] is Map<String, dynamic>
          ? SpecializationConditionsModel.fromJson(
              json['conditions'] as Map<String, dynamic>,
            )
          : const SpecializationConditionsModel(
              salary: 0,
              payPer: 'hour',
              requiredExperience: 0,
              scheduleType: 'full-time',
              formatType: 'remote',
            ),
      requirements: json['requirements'] as String? ?? '',
      vacancyId: json['vacancy_id'] as String?,
      isOccupied: json['is_occupied'] as bool? ?? false,
      occupiedByFreelancerId: json['occupied_by_freelancer_id'] as String?,
    );
  }

  /// Convert SpecializationOfferModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'specialization': specialization,
      'skill_level': skillLevel,
      'conditions': (conditions as SpecializationConditionsModel).toJson(),
      'requirements': requirements,
      if (vacancyId != null) 'vacancy_id': vacancyId,
      'is_occupied': isOccupied,
      if (occupiedByFreelancerId != null)
        'occupied_by_freelancer_id': occupiedByFreelancerId,
    };
  }

  /// Convert to domain entity
  SpecializationOffer toEntity() {
    return SpecializationOffer(
      specialization: specialization,
      skillLevel: skillLevel,
      conditions: conditions,
      requirements: requirements,
      vacancyId: vacancyId,
      isOccupied: isOccupied,
      occupiedByFreelancerId: occupiedByFreelancerId,
    );
  }

  /// Create a copy with updated values
  @override
  SpecializationOfferModel copyWith({
    String? specialization,
    String? skillLevel,
    SpecializationConditions? conditions,
    String? requirements,
    String? vacancyId,
    bool? isOccupied,
    String? occupiedByFreelancerId,
  }) {
    return SpecializationOfferModel(
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
}
