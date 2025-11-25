import 'package:flutter/foundation.dart';
import '../../../../shared/api/admin_api.dart';
import '../../../../shared/api/clients_api.dart';
import '../../../../shared/api/companies_api.dart';
import '../models/admin_order_model.dart';
import '../models/admin_client_model.dart';
import '../models/admin_company_model.dart';
import '../models/admin_project_model.dart';

class AdminProjectsRepository {
  final AdminApi adminApi;
  final ClientsApi clientsApi;
  final CompaniesApi companiesApi;

  const AdminProjectsRepository({
    required this.adminApi,
    required this.clientsApi,
    required this.companiesApi,
  });

  Future<List<AdminProjectModel>> fetchProjects({
    String? status,
    int page = 1,
    int size = 20,
  }) async {
    try {
      late final List<Map<String, dynamic>> responses;

      if (status == null || status == 'all') {
        // Fetch from both endpoints to get ALL orders
        final allOrdersResponse = await adminApi.getAllOrders(
          page: page,
          size: size,
        );
        final pendingOrdersResponse = await adminApi.getPendingOrders(
          page: page,
          size: size,
        );
        responses = [allOrdersResponse, pendingOrdersResponse];
      } else if (status == 'pending') {
        final response = await adminApi.getPendingOrders(
          page: page,
          size: size,
        );
        responses = [response];
      } else {
        final response = await adminApi.getOrdersByStatus(
          status: status,
          page: page,
          size: size,
        );
        responses = [response];
      }

      // Collect all orders from all responses
      final allOrders = <AdminOrderModel>[];

      for (final response in responses) {
        // Handle different response structures
        List<dynamic>? items;
        if (response['items'] != null) {
          final itemsData = response['items'];
          if (itemsData is List) {
            items = itemsData;
          } else if (itemsData is Map<String, dynamic>) {
            // Handle case where items is a Map (either single order or map of orders)
            if (itemsData.containsKey('order_id')) {
              // Single order object
              items = [itemsData];
            } else {
              // Map of orders keyed by ID
              items = itemsData.values.toList();
            }
          } else {
            items = null;
          }
        } else if (response['data'] != null &&
            response['data']['items'] != null) {
          final itemsData = response['data']['items'];
          if (itemsData is List) {
            items = itemsData;
          } else if (itemsData is Map<String, dynamic>) {
            if (itemsData.containsKey('order_id')) {
              items = [itemsData];
            } else {
              items = itemsData.values.toList();
            }
          } else {
            items = null;
          }
        } else {
          items = null;
        }

        if (items != null) {
          final orders = items
              .map((item) => item as Map<String, dynamic>)
              .map(AdminOrderModel.fromJson)
              .toList();
          allOrders.addAll(orders);
        }
      }

      // Remove duplicates based on order ID
      final uniqueOrders = <String, AdminOrderModel>{};
      for (final order in allOrders) {
        uniqueOrders[order.id] = order;
      }

      final orders = uniqueOrders.values.toList();

      if (orders.isEmpty) {
        return const [];
      }

      final companyIds = orders
          .map((order) => order.companyId)
          .where((id) => id.isNotEmpty)
          .toSet();

      // First load companies to get the correct client IDs
      final companies = await _loadCompanies(companyIds);

      // Collect all client IDs from both orders and companies
      final clientIds = <String>{};
      for (final order in orders) {
        if (order.clientId.isNotEmpty) {
          clientIds.add(order.clientId);
        }
      }
      for (final company in companies.values) {
        if (company.clientId != null && company.clientId!.isNotEmpty) {
          clientIds.add(company.clientId!);
        }
      }

      final clients = await _loadClients(clientIds);
      final projects = orders.map((order) {
        final company = companies[order.companyId];

        // Prefer client from company's clientId, fallback to order's clientId
        AdminClientModel? client;
        if (company?.clientId != null && company!.clientId!.isNotEmpty) {
          client = clients[company.clientId!];
        }
        client ??= clients[order.clientId];

        return AdminProjectModel(
          order: order,
          client:
              client ??
              AdminClientModel.fromJson({'client_id': order.clientId}),
          company:
              company ??
              AdminCompanyModel.fromJson({'company_id': order.companyId}),
        );
      }).toList();
      projects.sort((a, b) {
        final aDate =
            a.order.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.order.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return projects;
    } catch (error, stackTrace) {
      debugPrint('AdminProjectsRepository error: $error');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<List<AdminProjectModel>> fetchPendingProjects({
    int page = 1,
    int size = 20,
  }) async {
    return fetchProjects(status: 'pending', page: page, size: size);
  }

  Future<Map<String, AdminClientModel>> _loadClients(Set<String> ids) async {
    if (ids.isEmpty) {
      return const {};
    }
    final futures = ids.map((id) async {
      try {
        final data = await clientsApi.getClientById(id);
        return MapEntry(id, AdminClientModel.fromJson(data));
      } catch (e) {
        print('Error loading client $id: $e');
        // Return null for missing clients instead of crashing
        return null;
      }
    }).toList();
    final entries = await Future.wait(futures);
    final validEntries = entries
        .whereType<MapEntry<String, AdminClientModel>>();
    return {for (final entry in validEntries) entry.key: entry.value};
  }

  Future<Map<String, AdminCompanyModel>> _loadCompanies(Set<String> ids) async {
    if (ids.isEmpty) {
      return const {};
    }
    final futures = ids.map((id) async {
      try {
        final data = await companiesApi.getCompanyById(id);
        if (data != null) {
          return MapEntry(id, AdminCompanyModel.fromJson(data));
        }
        return null;
      } catch (e) {
        print('Error loading company $id: $e');
        return null;
      }
    }).toList();
    final entries = await Future.wait(futures);
    final validEntries = entries
        .whereType<MapEntry<String, AdminCompanyModel>>();
    return {for (final entry in validEntries) entry.key: entry.value};
  }
}
