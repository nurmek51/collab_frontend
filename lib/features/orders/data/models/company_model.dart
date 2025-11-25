/// Company model for data layer
class CompanyModel {
  final String? companyId;
  final String? clientId;
  final String? companyName;
  final String? companyIndustry;
  final String? clientPosition;
  final int? companySize;
  final String? companyLogo;
  final String? companyDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyModel({
    this.companyId,
    this.clientId,
    this.companyName,
    this.companyIndustry,
    this.clientPosition,
    this.companySize,
    this.companyLogo,
    this.companyDescription,
    this.createdAt,
    this.updatedAt,
  });

  /// Create CompanyModel from JSON
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['company_id']?.toString(),
      clientId: json['client_id']?.toString(),
      companyName: json['company_name']?.toString(),
      companyIndustry: json['company_industry']?.toString(),
      clientPosition: json['client_position']?.toString(),
      companySize: json['company_size'] is int
          ? json['company_size'] as int
          : null,
      companyLogo: json['company_logo']?.toString(),
      companyDescription: json['company_description']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Convert CompanyModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'client_id': clientId,
      'company_name': companyName,
      'company_industry': companyIndustry,
      'client_position': clientPosition,
      'company_size': companySize,
      'company_logo': companyLogo,
      'company_description': companyDescription,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
