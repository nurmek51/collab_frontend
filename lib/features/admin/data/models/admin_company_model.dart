class AdminCompanyModel {
  final String companyId;
  final String? clientId;
  final String? companyName;
  final String? clientPosition;
  final String? companyIndustry;
  final int? companySize;
  final String? companyLogo;
  final String? companyDescription;
  final List<String> companyOrders;
  final List<AdminCompanyOrderModel> orders;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminCompanyModel({
    required this.companyId,
    required this.clientId,
    required this.companyName,
    required this.clientPosition,
    required this.companyIndustry,
    required this.companySize,
    required this.companyLogo,
    required this.companyDescription,
    required this.companyOrders,
    required this.orders,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminCompanyModel.fromJson(Map<String, dynamic> json) {
    final ordersArray = json['orders'] as List?;
    final companyOrdersArray = json['company_orders'] as List?;
    return AdminCompanyModel(
      companyId: json['company_id'] as String? ?? '',
      clientId: json['client_id'] as String?,
      companyName: json['company_name'] as String?,
      clientPosition: json['client_position'] as String?,
      companyIndustry: json['company_industry'] as String?,
      companySize: json['company_size'] is int
          ? json['company_size'] as int
          : null,
      companyLogo: json['company_logo'] as String?,
      companyDescription: json['company_description'] as String?,
      companyOrders: companyOrdersArray == null
          ? const []
          : companyOrdersArray.whereType<String>().toList(growable: false),
      orders: ordersArray == null
          ? const []
          : ordersArray
                .whereType<Map<String, dynamic>>()
                .map(AdminCompanyOrderModel.fromJson)
                .toList(),
      createdAt: _parseDate(json['created_at'] as String?),
      updatedAt: _parseDate(json['updated_at'] as String?),
    );
  }
}

class AdminCompanyOrderModel {
  final String orderId;
  final String? companyId;
  final String? orderTitle;
  final String? orderDescription;
  final String? orderStatus;
  final String? orderCompleteStatus;
  final List<Map<String, dynamic>> orderColleagues;
  final List<Map<String, dynamic>> orderSpecializations;
  final String? chatLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminCompanyOrderModel({
    required this.orderId,
    required this.companyId,
    required this.orderTitle,
    required this.orderDescription,
    required this.orderStatus,
    required this.orderCompleteStatus,
    required this.orderColleagues,
    required this.orderSpecializations,
    required this.chatLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminCompanyOrderModel.fromJson(Map<String, dynamic> json) {
    final colleaguesArray = json['order_colleagues'] as List?;
    final specializationsArray = json['order_specializations'] as List?;
    return AdminCompanyOrderModel(
      orderId: json['order_id'] as String? ?? '',
      companyId: json['company_id'] as String?,
      orderTitle: json['order_title'] as String?,
      orderDescription: json['order_description'] as String?,
      orderStatus: json['order_status'] as String?,
      orderCompleteStatus: json['order_complete_status'] as String?,
      orderColleagues: colleaguesArray == null
          ? const []
          : colleaguesArray.whereType<Map<String, dynamic>>().toList(
              growable: false,
            ),
      orderSpecializations: specializationsArray == null
          ? const []
          : specializationsArray.whereType<Map<String, dynamic>>().toList(
              growable: false,
            ),
      chatLink: json['chat_link'] as String?,
      createdAt: _parseDate(json['created_at'] as String?),
      updatedAt: _parseDate(json['updated_at'] as String?),
    );
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
