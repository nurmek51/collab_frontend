import '../state/freelancer_onboarding_state.dart';
import 'client.dart';

class FreelancerApi {
  final ApiClient _client;

  FreelancerApi(this._client);

  Map<String, dynamic> _buildPayload(FreelancerOnboardingState state) {
    return state.toApiPayload();
  }

  Future<Map<String, dynamic>> createProfile(
    FreelancerOnboardingState state,
  ) async {
    return await _client.post<Map<String, dynamic>>(
      '/freelancers/profile',
      data: _buildPayload(state),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> updateProfile(
    FreelancerOnboardingState state,
  ) async {
    return await _client.put<Map<String, dynamic>>(
      '/freelancers/profile',
      data: _buildPayload(state),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await _client.get<Map<String, dynamic>>(
      '/freelancers/profile',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getFreelancers({
    int page = 1,
    int size = 20,
  }) async {
    return await _client.get<Map<String, dynamic>>(
      '/freelancers/',
      queryParameters: {'page': page, 'size': size},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getFreelancerById(String freelancerId) async {
    return await _client.get<Map<String, dynamic>>(
      '/freelancers/$freelancerId',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
