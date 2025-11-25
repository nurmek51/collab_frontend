import 'client.dart';
import '../../features/orders/data/models/application_model.dart';
import '../../features/orders/data/models/vacancy_application_models.dart';

/// Applications API endpoints with specialization/vacancy support
class ApplicationsApi {
  final ApiClient _client;

  ApplicationsApi(this._client);

  /// Create a new application with optional vacancy targeting
  Future<ApplicationModel> createApplication(
    OrderApplicationCreate request,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/applications/',
      data: request.toJson(),
      fromJson: (data) => data as Map<String, dynamic>,
    );
    return ApplicationModel.fromJson(response);
  }

  /// Apply to an order as a freelancer (legacy method - kept for backwards compatibility)
  @Deprecated('Use createApplication with OrderApplicationCreate instead')
  Future<Map<String, dynamic>> applyToOrder({
    required String orderId,
    required String freelancerId,
  }) async {
    return await _client.post<Map<String, dynamic>>(
      '/applications/',
      data: {'order_id': orderId, 'freelancer_id': freelancerId},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Check application eligibility for an order
  Future<EligibilityResponse> checkEligibility(
    String orderId, {
    String? vacancyId,
  }) async {
    final queryParams = <String, String>{};
    if (vacancyId != null) {
      queryParams['vacancy_id'] = vacancyId;
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/applications/eligibility/order/$orderId',
      queryParameters: queryParams.isEmpty ? null : queryParams,
      fromJson: (data) => data as Map<String, dynamic>,
    );
    return EligibilityResponse.fromJson(response);
  }

  /// Get freelancer's applications
  Future<List<ApplicationModel>> getMyApplications() async {
    final response = await _client.get<List<dynamic>>(
      '/applications/my',
      fromJson: (data) => data as List<dynamic>,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(ApplicationModel.fromJson)
        .toList();
  }

  /// Get applications for an order (for clients)
  Future<List<ApplicationModel>> getOrderApplications(String orderId) async {
    final response = await _client.get<List<dynamic>>(
      '/applications/order/$orderId',
      fromJson: (data) => data as List<dynamic>,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(ApplicationModel.fromJson)
        .toList();
  }

  /// Get applications for a specific specialization (for clients)
  Future<List<ApplicationModel>> getSpecializationApplications(
    String orderId,
    int specializationIndex,
  ) async {
    final response = await _client.get<List<dynamic>>(
      '/applications/order/$orderId/specialization/$specializationIndex',
      fromJson: (data) => data as List<dynamic>,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(ApplicationModel.fromJson)
        .toList();
  }

  /// Get available specializations for an order
  Future<List<AvailableSpecialization>> getAvailableSpecializations(
    String orderId,
  ) async {
    final response = await _client.get<List<dynamic>>(
      '/applications/order/$orderId/available-specializations',
      fromJson: (data) => data as List<dynamic>,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(AvailableSpecialization.fromJson)
        .toList();
  }

  /// Update application status (accept/reject)
  Future<ApplicationModel> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
  }) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/applications/$applicationId',
      data: {'status': status.value},
      fromJson: (data) => data as Map<String, dynamic>,
    );
    return ApplicationModel.fromJson(response);
  }

  /// Legacy method for updating application status with string
  @Deprecated('Use updateApplicationStatus with ApplicationStatus enum instead')
  Future<Map<String, dynamic>> updateApplicationStatusLegacy({
    required String applicationId,
    required String status,
  }) async {
    return await _client.put<Map<String, dynamic>>(
      '/applications/$applicationId',
      data: {'status': status},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
