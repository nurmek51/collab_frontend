class AdminOrderModel {
  final String id;
  final String companyId;
  final String clientId;
  final String? title;
  final String? description;
  final String? chatLink;
  final String status;
  final String? completeStatus;
  final List<AdminOrderSpecializationModel> specializations;
  final List<AdminOrderColleagueModel> colleagues;
  final List<String> orderColleagues; // List of freelancer IDs who applied
  final List<AdminOrderContractModel> contracts;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminOrderModel({
    required this.id,
    required this.companyId,
    required this.clientId,
    required this.title,
    required this.description,
    required this.chatLink,
    required this.status,
    required this.completeStatus,
    required this.specializations,
    required this.colleagues,
    required this.orderColleagues,
    required this.contracts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    // Handle both List and Map formats for nested objects
    List<dynamic> normalizeToList(dynamic data) {
      if (data == null) return [];
      if (data is List) return data;
      if (data is Map<String, dynamic>) return data.values.toList();
      return [];
    }

    final specializationsJson = normalizeToList(json['order_specializations']);
    final contractsJson = normalizeToList(json['contracts']);

    // Handle order_colleagues as freelancer IDs (List<String>)
    List<String> orderColleaguesIds = [];
    if (json['order_colleagues'] is List) {
      orderColleaguesIds = (json['order_colleagues'] as List)
          .where((item) => item is String)
          .cast<String>()
          .toList();
    }

    // Handle colleagues from a separate field if exists, otherwise empty list
    List<AdminOrderColleagueModel> colleagues = [];
    if (json['colleagues'] != null) {
      final colleaguesJson = normalizeToList(json['colleagues']);
      colleagues = colleaguesJson
          .whereType<Map<String, dynamic>>()
          .map(AdminOrderColleagueModel.fromJson)
          .toList();
    }

    return AdminOrderModel(
      id: json['order_id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      clientId: json['client_id'] as String? ?? '',
      title: json['order_title'] as String?,
      description: json['order_description'] as String?,
      chatLink: json['chat_link'] as String?,
      status: json['order_status'] as String? ?? '',
      completeStatus: json['order_complete_status'] as String?,
      specializations: specializationsJson
          .whereType<Map<String, dynamic>>()
          .map(AdminOrderSpecializationModel.fromJson)
          .toList(),
      colleagues: colleagues,
      orderColleagues: orderColleaguesIds,
      contracts: contractsJson
          .whereType<Map<String, dynamic>>()
          .map(AdminOrderContractModel.fromJson)
          .toList(),
      createdAt: _parseDate(json['created_at'] as String?),
      updatedAt: _parseDate(json['updated_at'] as String?),
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

class AdminOrderSpecializationModel {
  final String? specialization;
  final String? requirements;
  final String? skillLevel;
  final AdminOrderConditionsModel? conditions;
  final String? vacancyId;
  final bool? isOccupied;
  final String? occupiedByFreelancerId;

  const AdminOrderSpecializationModel({
    required this.specialization,
    required this.requirements,
    required this.skillLevel,
    required this.conditions,
    this.vacancyId,
    this.isOccupied,
    this.occupiedByFreelancerId,
  });

  factory AdminOrderSpecializationModel.fromJson(Map<String, dynamic> json) {
    final conditionsJson = json['conditions'];
    return AdminOrderSpecializationModel(
      specialization: json['specialization'] as String?,
      requirements: json['requirements'] as String?,
      skillLevel: json['skill_level'] as String?,
      conditions: conditionsJson is Map<String, dynamic>
          ? AdminOrderConditionsModel.fromJson(conditionsJson)
          : null,
      vacancyId: json['vacancy_id'] as String?,
      isOccupied: json['is_occupied'] as bool?,
      occupiedByFreelancerId: json['occupied_by_freelancer_id'] as String?,
    );
  }
}

class AdminOrderConditionsModel {
  final num? salary;
  final String? payPer;
  final num? requiredExperience;
  final String? scheduleType;
  final String? formatType;

  const AdminOrderConditionsModel({
    required this.salary,
    required this.payPer,
    required this.requiredExperience,
    required this.scheduleType,
    required this.formatType,
  });

  factory AdminOrderConditionsModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderConditionsModel(
      salary: json['salary'] is num ? json['salary'] as num : null,
      payPer: json['pay_per'] as String?,
      requiredExperience: json['required_experience'] is num
          ? json['required_experience'] as num
          : null,
      scheduleType: json['schedule_type'] as String?,
      formatType: json['format_type'] as String?,
    );
  }
}

class AdminOrderColleagueModel {
  final String? id;
  final String? name;
  final String? surname;
  final String? role;
  final String? position;
  final num? rate;
  final String? rateUnit;
  final String? status;
  final String? avatarUrl;

  const AdminOrderColleagueModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.role,
    required this.position,
    required this.rate,
    required this.rateUnit,
    required this.status,
    required this.avatarUrl,
  });

  factory AdminOrderColleagueModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderColleagueModel(
      id: json['id'] as String? ?? json['colleague_id'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      role: json['role'] as String? ?? json['position'] as String?,
      position: json['position'] as String?,
      rate: json['rate'] is num
          ? json['rate'] as num
          : json['salary'] is num
          ? json['salary'] as num
          : null,
      rateUnit:
          json['rate_unit'] as String? ??
          json['pay_per'] as String? ??
          json['rateType'] as String?,
      status: json['status'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
    );
  }

  String get displayName {
    final parts = <String>[];
    if (name != null && name!.isNotEmpty) {
      parts.add(name!);
    }
    if (surname != null && surname!.isNotEmpty) {
      parts.add(surname!);
    }
    if (parts.isEmpty && role != null && role!.isNotEmpty) {
      parts.add(role!);
    }
    return parts.join(' ');
  }
}

class AdminOrderContractModel {
  final String? id;
  final String? title;
  final String? url;
  final String? status;

  const AdminOrderContractModel({
    required this.id,
    required this.title,
    required this.url,
    required this.status,
  });

  factory AdminOrderContractModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderContractModel(
      id: json['id'] as String? ?? json['contract_id'] as String?,
      title:
          json['title'] as String? ??
          json['name'] as String? ??
          json['contract_title'] as String?,
      url: json['url'] as String? ?? json['document_url'] as String?,
      status: json['status'] as String?,
    );
  }
}
