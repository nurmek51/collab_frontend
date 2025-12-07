import 'specialization_offer_model.dart';

/// Order feed item model for the orders list API response
class OrderFeedModel {
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
  final List<dynamic>? contracts;
  final List<String>? orderColleagues;

  const OrderFeedModel({
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

  /// Get list of specialization names for compatibility
  List<String> get specializationNames {
    return orderSpecializations.map((offer) => offer.specialization).toList();
  }

  /// Check if order has any available (non-occupied) specializations
  bool get hasAvailableSpecializations {
    return orderSpecializations.any((spec) => !spec.isOccupied);
  }

  /// Get only available specializations
  List<SpecializationOfferModel> get availableSpecializations {
    return orderSpecializations.where((spec) => !spec.isOccupied).toList();
  }

  /// Create OrderFeedModel from JSON
  factory OrderFeedModel.fromJson(Map<String, dynamic> json) {
    return OrderFeedModel(
      orderId: json['order_id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      orderDescription: json['order_description'] as String? ?? '',
      orderStatus: json['order_status'] as String? ?? '',
      orderCompleteStatus: json['order_complete_status'] as String? ?? '',
      orderTitle: json['order_title'] as String? ?? '',
      orderSpecializations: _parseSpecializationOffers(
        json['order_specializations'],
      ),
      chatLink: json['chat_link'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      contracts: json['contracts'] as List<dynamic>?,
      orderColleagues: json['order_colleagues'] != null
          ? (json['order_colleagues'] as List<dynamic>).cast<String>()
          : null,
    );
  }

  /// Convert OrderFeedModel to JSON
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

/// Paginated response for orders feed
class OrdersFeedResponse {
  final List<OrderFeedModel> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  const OrdersFeedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  /// Create OrdersFeedResponse from JSON
  factory OrdersFeedResponse.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return OrdersFeedResponse(
      items: items is List<dynamic>
          ? items
                .whereType<Map<String, dynamic>>()
                .map((item) => OrderFeedModel.fromJson(item))
                .toList()
          : [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 20,
      pages: json['pages'] as int? ?? 0,
    );
  }
}
