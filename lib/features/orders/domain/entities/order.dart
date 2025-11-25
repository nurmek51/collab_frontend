import 'team_member.dart';

/// Order entity representing a client order
class Order {
  final String id;
  final String title;
  final String description;
  final String status;
  final String? completeStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? companyId;
  final String? telegramChatLink;
  final Map<String, dynamic>? documents;
  final String? projectName;
  final String? projectLogo;
  final List<dynamic>? orderSpecializations;
  final List<TeamMember>? teamMembers;
  final double? monthlyTotal;
  final List<String>? specializations;
  final String? paymentType;
  final double? hourlyRate;

  const Order({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.completeStatus,
    this.companyId,
    this.telegramChatLink,
    this.documents,
    this.projectName,
    this.projectLogo,
    this.orderSpecializations,
    this.teamMembers,
    this.monthlyTotal,
    this.specializations,
    this.paymentType,
    this.hourlyRate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.completeStatus == completeStatus &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.companyId == companyId &&
        other.telegramChatLink == telegramChatLink &&
        other.documents == documents &&
        other.projectName == projectName &&
        other.projectLogo == projectLogo &&
        other.orderSpecializations == orderSpecializations &&
        other.teamMembers == teamMembers &&
        other.monthlyTotal == monthlyTotal;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        status.hashCode ^
        completeStatus.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        companyId.hashCode ^
        telegramChatLink.hashCode ^
        documents.hashCode ^
        projectName.hashCode ^
        projectLogo.hashCode ^
        orderSpecializations.hashCode ^
        teamMembers.hashCode ^
        monthlyTotal.hashCode;
  }
}
