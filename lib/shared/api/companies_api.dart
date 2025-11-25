import 'client.dart';

/// Companies API endpoints
class CompaniesApi {
  final ApiClient _client;

  CompaniesApi(this._client);

  /// Create a new company
  Future<Map<String, dynamic>> createCompany({
    required String companyName,
    required String companyIndustry,
    required String clientPosition,
    required int companySize,
    String? companyLogo,
    String? companyDescription,
  }) async {
    final data = {
      'company_name': companyName,
      'company_industry': companyIndustry,
      'client_position': clientPosition,
      'company_size': companySize,
    };

    if (companyLogo != null && companyLogo.isNotEmpty) {
      data['company_logo'] = companyLogo;
    }
    if (companyDescription != null && companyDescription.isNotEmpty) {
      data['company_description'] = companyDescription;
    }

    return await _client.post<Map<String, dynamic>>(
      '/companies/',
      data: data,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Get current client's companies
  Future<List<Map<String, dynamic>>> getMyCompanies() async {
    return await _client.get<List<Map<String, dynamic>>>(
      '/companies/my',
      fromJson: (data) {
        if (data is List) {
          return data.whereType<Map<String, dynamic>>().toList(growable: false);
        }
        return const <Map<String, dynamic>>[];
      },
    );
  }

  /// Get company details by ID
  Future<Map<String, dynamic>?> getCompanyById(String companyId) async {
    return await _client.get<Map<String, dynamic>?>(
      '/companies/id/$companyId',
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is List && data.isEmpty) {
          // API returns empty array when company not found or has no data
          return null;
        }
        return null;
      },
    );
  }

  /// Get all companies for a specific client
  Future<List<Map<String, dynamic>>> getCompaniesByClientId(
    String clientId,
  ) async {
    return await _client.get<List<Map<String, dynamic>>>(
      '/companies/$clientId',
      fromJson: (data) {
        if (data is List) {
          return data.whereType<Map<String, dynamic>>().toList(growable: false);
        }
        return const <Map<String, dynamic>>[];
      },
    );
  }
}
