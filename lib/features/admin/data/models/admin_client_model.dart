class AdminClientModel {
  final String clientId;
  final String? userId;
  final String? name;
  final String? surname;
  final String? phoneNumber;
  final List<String> companyIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminClientModel({
    required this.clientId,
    required this.userId,
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.companyIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminClientModel.fromJson(Map<String, dynamic> json) {
    final ids = json['company_ids'] as List?;
    return AdminClientModel(
      clientId: json['client_id'] as String? ?? '',
      userId: json['user_id'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      phoneNumber: json['phone_number'] as String?,
      companyIds: ids == null
          ? const []
          : ids.whereType<String>().toList(growable: false),
      createdAt: _parseDate(json['created_at'] as String?),
      updatedAt: _parseDate(json['updated_at'] as String?),
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
    if (parts.isEmpty) {
      parts.add('Клиент');
    }
    return parts.join(' ');
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
