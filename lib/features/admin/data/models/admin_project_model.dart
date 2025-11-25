import 'admin_order_model.dart';
import 'admin_client_model.dart';
import 'admin_company_model.dart';

class AdminProjectModel {
  final AdminOrderModel order;
  final AdminClientModel client;
  final AdminCompanyModel company;

  const AdminProjectModel({
    required this.order,
    required this.client,
    required this.company,
  });

  String get displayName {
    if (company.companyName != null && company.companyName!.isNotEmpty) {
      return company.companyName!;
    }
    if (order.title != null && order.title!.isNotEmpty) {
      return order.title!;
    }
    return 'Проект';
  }
}
