import 'package:formz/formz.dart';

enum PhoneValidationError { empty, invalid }

class PhoneNumber extends FormzInput<String, PhoneValidationError> {
  const PhoneNumber.pure() : super.pure('');
  const PhoneNumber.dirty([super.value = '']) : super.dirty();

  static final RegExp _normalizedPhoneRegex = RegExp(r'^\+\d{7,15}$');

  static String normalize(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('+')) {
      return cleaned;
    }

    if (cleaned.startsWith('8') && cleaned.length == 11) {
      return '+7${cleaned.substring(1)}';
    }

    if (cleaned.startsWith('7') && cleaned.length == 11) {
      return '+$cleaned';
    }

    if (cleaned.isNotEmpty) {
      return '+$cleaned';
    }

    return cleaned;
  }

  @override
  PhoneValidationError? validator(String value) {
    if (value.isEmpty) {
      return PhoneValidationError.empty;
    }

    final normalized = normalize(value);

    if (!_normalizedPhoneRegex.hasMatch(normalized)) {
      return PhoneValidationError.invalid;
    }

    return null;
  }

  String? get errorMessage {
    switch (error) {
      case PhoneValidationError.empty:
        return 'Phone number is required';
      case PhoneValidationError.invalid:
        return 'Invalid phone number format';
      case null:
        return null;
    }
  }

  String get normalizedValue => normalize(value);
}
