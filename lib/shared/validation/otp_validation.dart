import 'package:formz/formz.dart';

/// OTP validation for exactly 6 digits
enum OtpValidationError { empty, invalid, tooShort, tooLong }

class OtpCode extends FormzInput<String, OtpValidationError> {
  const OtpCode.pure() : super.pure('');
  const OtpCode.dirty([super.value = '']) : super.dirty();

  /// Regex for exactly 6 digits
  static final RegExp _otpRegex = RegExp(r'^\d{6}$');

  @override
  OtpValidationError? validator(String value) {
    if (value.isEmpty) {
      return OtpValidationError.empty;
    }

    if (value.length < 6) {
      return OtpValidationError.tooShort;
    }

    if (value.length > 6) {
      return OtpValidationError.tooLong;
    }

    if (!_otpRegex.hasMatch(value)) {
      return OtpValidationError.invalid;
    }

    return null;
  }

  /// Get error message for display
  String? get errorMessage {
    switch (error) {
      case OtpValidationError.empty:
        return 'OTP code is required';
      case OtpValidationError.invalid:
        return 'OTP must contain only digits';
      case OtpValidationError.tooShort:
        return 'OTP must be 6 digits';
      case OtpValidationError.tooLong:
        return 'OTP must be exactly 6 digits';
      case null:
        return null;
    }
  }

  /// Check if OTP is complete (6 digits)
  bool get isComplete => value.length == 6 && isValid;
}
