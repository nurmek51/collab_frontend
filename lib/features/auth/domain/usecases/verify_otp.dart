import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

/// Use case for verifying OTP and authenticating user
class VerifyOtp {
  final AuthRepository _repository;

  VerifyOtp(this._repository);

  /// Verify OTP and return authentication response
  Future<AuthResponse> call(String phoneNumber, String otp) async {
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number cannot be empty');
    }

    if (otp.isEmpty) {
      throw Exception('OTP cannot be empty');
    }

    // OTP validation
    if (otp.length != 4 || !RegExp(r'^\d{4}$').hasMatch(otp)) {
      throw Exception('OTP must be exactly 4 digits');
    }

    // Clean phone number
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    return await _repository.verifyOtp(cleanPhone, otp);
  }
}
