/// Application status enum for type safety
enum ApplicationStatus {
  pending,
  accepted,
  rejected;

  static ApplicationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case ApplicationStatus.pending:
        return 'pending';
      case ApplicationStatus.accepted:
        return 'accepted';
      case ApplicationStatus.rejected:
        return 'rejected';
    }
  }
}

/// Application model for freelancer applications with specialization support
class ApplicationModel {
  final String id;
  final String orderId;
  final String freelancerId;
  final String companyId;
  final ApplicationStatus status;
  final int? specializationIndex;
  final String? specializationName;
  final String? vacancyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApplicationModel({
    required this.id,
    required this.orderId,
    required this.freelancerId,
    required this.companyId,
    required this.status,
    this.specializationIndex,
    this.specializationName,
    this.vacancyId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if this is a specialization-specific application
  bool get isSpecializationApplication => vacancyId != null;

  /// Check if this is a general order application
  bool get isGeneralApplication => vacancyId == null;

  /// Create ApplicationModel from JSON
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      freelancerId: json['freelancer_id'] as String,
      companyId: json['company_id'] as String,
      status: ApplicationStatus.fromString(json['status'] as String),
      specializationIndex: json['specialization_index'] as int?,
      specializationName: json['specialization_name'] as String?,
      vacancyId: json['vacancy_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert ApplicationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'freelancer_id': freelancerId,
      'company_id': companyId,
      'status': status.value,
      if (specializationIndex != null)
        'specialization_index': specializationIndex,
      if (specializationName != null) 'specialization_name': specializationName,
      if (vacancyId != null) 'vacancy_id': vacancyId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  ApplicationModel copyWith({
    ApplicationStatus? status,
    int? specializationIndex,
    String? specializationName,
    String? vacancyId,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      id: id,
      orderId: orderId,
      freelancerId: freelancerId,
      companyId: companyId,
      status: status ?? this.status,
      specializationIndex: specializationIndex ?? this.specializationIndex,
      specializationName: specializationName ?? this.specializationName,
      vacancyId: vacancyId ?? this.vacancyId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
