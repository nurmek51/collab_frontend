import 'package:formz/formz.dart';

/// IIN validation for Kazakhstan (12 digits)
enum IinValidationError { empty, invalid, wrongLength }

class Iin extends FormzInput<String, IinValidationError> {
  const Iin.pure() : super.pure('');
  const Iin.dirty([super.value = '']) : super.dirty();

  /// Regex for exactly 12 digits
  static final RegExp _iinRegex = RegExp(r'^\d{12}$');

  @override
  IinValidationError? validator(String value) {
    if (value.isEmpty) {
      return IinValidationError.empty;
    }

    if (value.length != 12) {
      return IinValidationError.wrongLength;
    }

    if (!_iinRegex.hasMatch(value)) {
      return IinValidationError.invalid;
    }

    return null;
  }

  String? get errorMessage {
    switch (error) {
      case IinValidationError.empty:
        return 'IIN is required';
      case IinValidationError.invalid:
        return 'IIN must contain only digits';
      case IinValidationError.wrongLength:
        return 'IIN must be exactly 12 digits';
      case null:
        return null;
    }
  }
}

/// Email validation
enum EmailValidationError { empty, invalid }

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');
  const Email.dirty([super.value = '']) : super.dirty();

  /// RFC 5322 compliant email regex (simplified)
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) {
      return EmailValidationError.empty;
    }

    if (!_emailRegex.hasMatch(value)) {
      return EmailValidationError.invalid;
    }

    return null;
  }

  String? get errorMessage {
    switch (error) {
      case EmailValidationError.empty:
        return 'Email is required';
      case EmailValidationError.invalid:
        return 'Please enter a valid email address';
      case null:
        return null;
    }
  }
}

/// City validation
enum CityValidationError { empty }

class City extends FormzInput<String, CityValidationError> {
  const City.pure() : super.pure('');
  const City.dirty([super.value = '']) : super.dirty();

  @override
  CityValidationError? validator(String value) {
    if (value.trim().isEmpty) {
      return CityValidationError.empty;
    }
    return null;
  }

  String? get errorMessage {
    switch (error) {
      case CityValidationError.empty:
        return 'City is required';
      case null:
        return null;
    }
  }
}

/// Name validation (required field)
enum NameValidationError { empty, invalid }

class Name extends FormzInput<String, NameValidationError> {
  const Name.pure() : super.pure('');
  const Name.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String value) {
    if (value.trim().isEmpty) {
      return NameValidationError.empty;
    }
    return null;
  }

  String? get errorMessage {
    switch (error) {
      case NameValidationError.empty:
        return 'Name is required';
      case NameValidationError.invalid:
        return 'Please enter a valid name';
      case null:
        return null;
    }
  }
}

/// URL validation for social links and portfolio
enum UrlValidationError { invalid }

class UrlField extends FormzInput<String, UrlValidationError> {
  const UrlField.pure() : super.pure('');
  const UrlField.dirty([super.value = '']) : super.dirty();

  /// URL regex for https and http
  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$',
  );

  @override
  UrlValidationError? validator(String value) {
    // URL is optional, so empty is valid
    if (value.isEmpty) return null;

    if (!_urlRegex.hasMatch(value)) {
      return UrlValidationError.invalid;
    }

    return null;
  }

  String? get errorMessage {
    switch (error) {
      case UrlValidationError.invalid:
        return 'Please enter a valid URL (https://...)';
      case null:
        return null;
    }
  }
}
