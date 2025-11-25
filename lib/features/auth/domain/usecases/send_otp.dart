import '../repositories/auth_repository.dart';

/// Use case for sending OTP to phone number
class SendOtp {
  final AuthRepository _repository;

  SendOtp(this._repository);

  /// Send OTP to the given phone number
  Future<void> call(String phoneNumber, {String? role}) async {
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number cannot be empty');
    }

    // Basic phone number validation
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.length < 10) {
      throw Exception('Invalid phone number format');
    }

    await _repository.sendOtp(cleanPhone, role: role);
  }
}
