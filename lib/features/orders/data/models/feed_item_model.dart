import '../../domain/entities/feed_item.dart';
import 'specialization_offer_model.dart';

/// Feed item model for data layer
class FeedItemModel extends FeedItem {
  const FeedItemModel({
    required super.id,
    required super.companyName,
    super.companyLogo,
    required super.taskTitle,
    required super.taskDescription,
    required super.specializationOffers,
    required super.createdAt,
    super.budget,
    super.projectType,
    super.chatLink,
  });

  /// Create FeedItemModel from JSON based on new order model structure
  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: json['order_id']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      companyLogo: json['company_logo']?.toString(),
      taskTitle: json['order_title']?.toString() ?? '',
      taskDescription: json['order_description']?.toString() ?? '',
      specializationOffers: _parseSpecializationOffers(
        json['order_specializations'],
      ),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      budget: json['budget']?.toString(),
      projectType: json['project_type']?.toString(),
      chatLink: json['chat_link']?.toString(),
    );
  }

  /// Parse specialization offers from the new API format
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

  /// Convert FeedItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'order_id': id,
      'company_name': companyName,
      'company_logo': companyLogo,
      'order_title': taskTitle,
      'order_description': taskDescription,
      'order_specializations': specializationOffers
          .map((offer) => (offer as SpecializationOfferModel).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'budget': budget,
      'project_type': projectType,
      'chat_link': chatLink,
    };
  }

  /// Convert to domain entity
  FeedItem toEntity() {
    return FeedItem(
      id: id,
      companyName: companyName,
      companyLogo: companyLogo,
      taskTitle: taskTitle,
      taskDescription: taskDescription,
      specializationOffers: specializationOffers,
      createdAt: createdAt,
      budget: budget,
      projectType: projectType,
      chatLink: chatLink,
    );
  }
}
