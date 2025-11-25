import 'specialization_offer.dart';

/// Feed item entity representing a project in the freelancer feed
class FeedItem {
  final String id;
  final String companyName;
  final String? companyLogo;
  final String taskTitle;
  final String taskDescription;
  final List<SpecializationOffer> specializationOffers;
  final DateTime createdAt;
  final String? budget;
  final String? projectType;
  final String? chatLink;

  const FeedItem({
    required this.id,
    required this.companyName,
    this.companyLogo,
    required this.taskTitle,
    required this.taskDescription,
    required this.specializationOffers,
    required this.createdAt,
    this.budget,
    this.projectType,
    this.chatLink,
  });

  /// Get list of specialization names for compatibility
  List<String> get specializations {
    return specializationOffers.map((offer) => offer.specialization).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedItem &&
        other.id == id &&
        other.companyName == companyName &&
        other.companyLogo == companyLogo &&
        other.taskTitle == taskTitle &&
        other.taskDescription == taskDescription &&
        other.specializationOffers == specializationOffers &&
        other.createdAt == createdAt &&
        other.budget == budget &&
        other.projectType == projectType &&
        other.chatLink == chatLink;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      companyName,
      companyLogo,
      taskTitle,
      taskDescription,
      specializationOffers,
      createdAt,
      budget,
      projectType,
      chatLink,
    );
  }

  @override
  String toString() {
    return 'FeedItem(id: $id, companyName: $companyName, taskTitle: $taskTitle)';
  }
}
