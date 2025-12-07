import '../../domain/entities/order.dart';
import 'team_member_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    required super.createdAt,
    super.updatedAt,
    super.completeStatus,
    super.companyId,
    super.telegramChatLink,
    super.documents,
    super.contracts,
    super.projectName,
    super.projectLogo,
    super.orderSpecializations,
    super.teamMembers,
    super.monthlyTotal,
    super.specializations,
    super.paymentType,
    super.hourlyRate,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['order_id']?.toString() ?? '',
      title: json['order_title']?.toString() ?? '',
      description: json['order_description']?.toString() ?? '',
      status: json['order_status']?.toString() ?? '',
      completeStatus: json['order_complete_status']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      companyId: json['company_id']?.toString(),
      telegramChatLink: json['chat_link']?.toString(),
      documents: json['documents'] as Map<String, dynamic>?,
      contracts: json['contracts'] is List
          ? json['contracts'] as List<dynamic>
          : null,
      orderSpecializations:
          json['order_specializations'] != null &&
              json['order_specializations'] is List
          ? json['order_specializations'] as List<dynamic>
          : null,
      projectName: json['project_name']?.toString(),
      projectLogo: json['project_logo']?.toString(),
      teamMembers: json['team_members'] != null && json['team_members'] is List
          ? (json['team_members'] as List<dynamic>)
                .where((member) => member is Map<String, dynamic>)
                .map(
                  (member) =>
                      TeamMemberModel.fromJson(member as Map<String, dynamic>),
                )
                .toList()
          : null,
      monthlyTotal: json['monthly_total'] != null
          ? (json['monthly_total'] as num).toDouble()
          : null,
      specializations:
          json['specializations'] != null && json['specializations'] is List
          ? (json['specializations'] as List<dynamic>)
                .where((spec) => spec != null)
                .map((spec) => spec.toString())
                .toList()
          : null,
      paymentType: json['payment_type']?.toString(),
      hourlyRate: json['hourly_rate'] != null && json['hourly_rate'] is num
          ? (json['hourly_rate'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': id,
      'order_title': title,
      'order_description': description,
      'order_status': status,
      'order_complete_status': completeStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'company_id': companyId,
      'chat_link': telegramChatLink,
      'documents': documents,
      'contracts': contracts,
      'order_specializations': orderSpecializations,
      'project_name': projectName,
      'project_logo': projectLogo,
      'team_members': teamMembers
          ?.map((member) => TeamMemberModel.fromEntity(member).toJson())
          .toList(),
      'monthly_total': monthlyTotal,
      'specializations': specializations,
      'payment_type': paymentType,
      'hourly_rate': hourlyRate,
    };
  }

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      title: order.title,
      description: order.description,
      status: order.status,
      completeStatus: order.completeStatus,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      companyId: order.companyId,
      telegramChatLink: order.telegramChatLink,
      documents: order.documents,
      contracts: order.contracts,
      projectName: order.projectName,
      projectLogo: order.projectLogo,
      orderSpecializations: order.orderSpecializations,
      teamMembers: order.teamMembers,
      monthlyTotal: order.monthlyTotal,
      specializations: order.specializations,
      paymentType: order.paymentType,
      hourlyRate: order.hourlyRate,
    );
  }
}
