import 'package:dio/dio.dart';

import '../state/freelancer_onboarding_state.dart';
import '../utils/resume_file_utils.dart';
import 'client.dart';
import 'resume_models.dart';

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

  Future<ResumeUploadResult> uploadResume({
    required String fileName,
    required List<int> fileBytes,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
        contentType: mimeTypeForResumeFile(fileName),
      ),
    });

    return _client.postMultipart<ResumeUploadResult>(
      '/freelancers/profile/resume',
      data: formData,
      onSendProgress: onSendProgress,
      fromJson: (data) =>
          ResumeUploadResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ResumeDownloadResult> getResumeDownloadUrl() async {
    return _client.get<ResumeDownloadResult>(
      '/freelancers/profile/resume',
      fromJson: (data) =>
          ResumeDownloadResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ResumeDeleteResult> deleteResume() async {
    return _client.delete<ResumeDeleteResult>(
      '/freelancers/profile/resume',
      fromJson: (data) =>
          ResumeDeleteResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
