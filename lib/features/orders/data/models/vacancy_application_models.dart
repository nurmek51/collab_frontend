/// Models for the specialization/vacancy application system

/// Application request data for creating applications
class OrderApplicationCreate {
  final String orderId;
  final String? vacancyId;
  final String? freelancerId;

  const OrderApplicationCreate({
    required this.orderId,
    this.vacancyId,
    this.freelancerId,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      if (vacancyId != null) 'vacancy_id': vacancyId,
      if (freelancerId != null) 'freelancer_id': freelancerId,
    };
  }
}

/// Eligibility check response
class EligibilityResponse {
  final bool eligible;
  final String reason;

  const EligibilityResponse({required this.eligible, required this.reason});

  /// Create from JSON response
  factory EligibilityResponse.fromJson(Map<String, dynamic> json) {
    return EligibilityResponse(
      eligible: json['eligible'] as bool,
      reason: json['reason'] as String,
    );
  }
}

/// Available specialization model with vacancy information
class AvailableSpecialization {
  final int index;
  final String specialization;
  final String skillLevel;
  final Map<String, dynamic>? conditions;
  final String? requirements;
  final String vacancyId;
  final bool isOccupied;
  final String? occupiedByFreelancerId;

  const AvailableSpecialization({
    required this.index,
    required this.specialization,
    required this.skillLevel,
    this.conditions,
    this.requirements,
    required this.vacancyId,
    required this.isOccupied,
    this.occupiedByFreelancerId,
  });

  /// Create from JSON response
  factory AvailableSpecialization.fromJson(Map<String, dynamic> json) {
    return AvailableSpecialization(
      index: json['index'] as int,
      specialization: json['specialization'] as String,
      skillLevel: json['skill_level'] as String,
      conditions: json['conditions'] as Map<String, dynamic>?,
      requirements: json['requirements'] as String?,
      vacancyId: json['vacancy_id'] as String,
      isOccupied: json['is_occupied'] as bool,
      occupiedByFreelancerId: json['occupied_by_freelancer_id'] as String?,
    );
  }

  /// Check if this specialization is available for application
  bool get isAvailable => !isOccupied;
}

/// Order specialization with vacancy support
class OrderSpecialization {
  final String specialization;
  final String skillLevel;
  final Map<String, dynamic>? conditions;
  final String? requirements;
  final String vacancyId;
  final bool isOccupied;
  final String? occupiedByFreelancerId;

  const OrderSpecialization({
    required this.specialization,
    required this.skillLevel,
    this.conditions,
    this.requirements,
    required this.vacancyId,
    required this.isOccupied,
    this.occupiedByFreelancerId,
  });

  /// Create from JSON response
  factory OrderSpecialization.fromJson(Map<String, dynamic> json) {
    return OrderSpecialization(
      specialization: json['specialization'] as String,
      skillLevel: json['skill_level'] as String,
      conditions: json['conditions'] as Map<String, dynamic>?,
      requirements: json['requirements'] as String?,
      vacancyId: json['vacancy_id'] as String,
      isOccupied: json['is_occupied'] as bool? ?? false,
      occupiedByFreelancerId: json['occupied_by_freelancer_id'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'specialization': specialization,
      'skill_level': skillLevel,
      if (conditions != null) 'conditions': conditions,
      if (requirements != null) 'requirements': requirements,
      'vacancy_id': vacancyId,
      'is_occupied': isOccupied,
      if (occupiedByFreelancerId != null)
        'occupied_by_freelancer_id': occupiedByFreelancerId,
    };
  }

  /// Check if this specialization is available for application
  bool get isAvailable => !isOccupied;

  /// Create a copy with updated occupation status
  OrderSpecialization copyWith({
    bool? isOccupied,
    String? occupiedByFreelancerId,
  }) {
    return OrderSpecialization(
      specialization: specialization,
      skillLevel: skillLevel,
      conditions: conditions,
      requirements: requirements,
      vacancyId: vacancyId,
      isOccupied: isOccupied ?? this.isOccupied,
      occupiedByFreelancerId:
          occupiedByFreelancerId ?? this.occupiedByFreelancerId,
    );
  }
}
