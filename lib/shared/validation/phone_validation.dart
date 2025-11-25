import 'package:formz/formz.dart';

/// Phone number validation for Kazakhstan and Russia only
enum PhoneValidationError { empty, invalid, unsupportedCountry }

class PhoneNumber extends FormzInput<String, PhoneValidationError> {
  const PhoneNumber.pure() : super.pure('');
  const PhoneNumber.dirty([super.value = '']) : super.dirty();

  /// Regex for Kazakhstan and Russia phone numbers
  /// Supports formats: +7XXXXXXXXXX, 7XXXXXXXXXX, 8XXXXXXXXXX
  static final RegExp _phoneRegex = RegExp(r'^(\+?7|8)[0-9]{10}$');

  /// Normalize phone number to +7XXXXXXXXXX format
  static String normalize(String phone) {
    // Remove all non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Handle different formats
    if (cleaned.startsWith('+7') && cleaned.length == 12) {
      return cleaned; // Already in correct format
    } else if (cleaned.startsWith('7') && cleaned.length == 11) {
      return '+$cleaned'; // Add + prefix
    } else if (cleaned.startsWith('8') && cleaned.length == 11) {
      return '+7${cleaned.substring(1)}'; // Replace 8 with +7
    }

    return cleaned; // Return as-is for validation to catch
  }

  /// Check if phone number is from Kazakhstan or Russia
  static bool isKazakhstanOrRussia(String phone) {
    final normalized = normalize(phone);
    if (!normalized.startsWith('+7') || normalized.length != 12) {
      return false;
    }

    // Extract the first digit after +7
    final firstDigit = normalized.substring(2, 3);

    // Kazakhstan: +7 6XX, +7 7XX (mobile)
    // Russia: +7 9XX (mobile), +7 3XX-5XX, +7 8XX (regional)
    return firstDigit == '6' ||
        firstDigit == '7' ||
        firstDigit == '9' ||
        firstDigit == '3' ||
        firstDigit == '4' ||
        firstDigit == '5' ||
        firstDigit == '8';
  }

  @override
  PhoneValidationError? validator(String value) {
    if (value.isEmpty) {
      return PhoneValidationError.empty;
    }

    final normalized = normalize(value);

    if (!_phoneRegex.hasMatch(normalized.replaceAll('+', ''))) {
      return PhoneValidationError.invalid;
    }

    if (!isKazakhstanOrRussia(value)) {
      return PhoneValidationError.unsupportedCountry;
    }

    return null;
  }

  /// Get error message for display
  String? get errorMessage {
    switch (error) {
      case PhoneValidationError.empty:
        return 'Phone number is required';
      case PhoneValidationError.invalid:
        return 'Invalid phone number format';
      case PhoneValidationError.unsupportedCountry:
        return 'Please enter a valid Kazakhstan (+7 7XX) or Russia (+7 9XX) phone number';
      case null:
        return null;
    }
  }

  /// Get normalized value for API calls
  String get normalizedValue => normalize(value);
}
