import 'specialization_offer_model.dart';

/// Order condition model (kept for backwards compatibility but not used in new API)
class OrderConditionModel {
  final double salary;
  final String payPer;
  final int requiredExperience;
  final String scheduleType;
  final String formatType;

  const OrderConditionModel({
    required this.salary,
    required this.payPer,
    required this.requiredExperience,
    required this.scheduleType,
    required this.formatType,
  });

  /// Create OrderConditionModel from JSON
  factory OrderConditionModel.fromJson(Map<String, dynamic> json) {
    return OrderConditionModel(
      salary: (json['salary'] as num).toDouble(),
      payPer: json['pay_per'] as String,
      requiredExperience: json['required_experience'] as int,
      scheduleType: json['schedule_type'] as String,
      formatType: json['format_type'] as String,
    );
  }

  /// Convert OrderConditionModel to JSON
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

/// Detailed order model for single order API response
class OrderDetailsModel {
  final String orderId;
  final String companyId;
  final String orderDescription;
  final String orderStatus;
  final String orderCompleteStatus;
  final String orderTitle;
  final List<SpecializationOfferModel> orderSpecializations;
  final String? chatLink;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? contracts;
  final List<String>? orderColleagues;

  const OrderDetailsModel({
    required this.orderId,
    required this.companyId,
    required this.orderDescription,
    required this.orderStatus,
    required this.orderCompleteStatus,
    required this.orderTitle,
    required this.orderSpecializations,
    this.chatLink,
    required this.createdAt,
    this.updatedAt,
    this.contracts,
    this.orderColleagues,
  });

  /// Create OrderDetailsModel from JSON
  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      orderId: json['order_id'] as String,
      companyId: json['company_id'] as String,
      orderDescription: json['order_description'] as String,
      orderStatus: json['order_status'] as String,
      orderCompleteStatus: json['order_complete_status'] as String,
      orderTitle: json['order_title'] as String,
      orderSpecializations: _parseSpecializationOffers(
        json['order_specializations'],
      ),
      chatLink: json['chat_link'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      contracts: json['contracts'] as Map<String, dynamic>?,
      orderColleagues: json['order_colleagues'] != null
          ? (json['order_colleagues'] as List<dynamic>).cast<String>()
          : null,
    );
  }

  /// Convert OrderDetailsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'company_id': companyId,
      'order_description': orderDescription,
      'order_status': orderStatus,
      'order_complete_status': orderCompleteStatus,
      'order_title': orderTitle,
      'order_specializations': orderSpecializations
          .map((offer) => offer.toJson())
          .toList(),
      'chat_link': chatLink,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (contracts != null) 'contracts': contracts,
      if (orderColleagues != null) 'order_colleagues': orderColleagues,
    };
  }

  /// Helper method to parse specialization offers from the new API format
  static List<SpecializationOfferModel> _parseSpecializationOffers(
    dynamic data,
  ) {
    if (data is List<dynamic>) {
      return data
          .map((item) {
            if (item is Map<String, dynamic>) {
              return SpecializationOfferModel.fromJson(item);
            }
            return null;
          })
          .where((item) => item != null)
          .cast<SpecializationOfferModel>()
          .toList();
    }
    return [];
  }
}
