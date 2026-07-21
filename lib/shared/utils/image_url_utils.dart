import '../../core/config/app_config.dart';

/// Converts image values returned by the API into URLs that Flutter can load.
///
/// The backend may return an absolute URL, a protocol-relative URL, or a path
/// such as `/uploads/company-logo.png`. A path must be resolved against the API
/// host rather than the web application's host.
String? resolveImageUrl(String? value) {
  final rawValue = value?.trim();
  if (rawValue == null || rawValue.isEmpty) return null;

  final valueWithoutQuotes = _removeWrappingQuotes(rawValue);
  if (valueWithoutQuotes.isEmpty) return null;

  final parsed = Uri.tryParse(valueWithoutQuotes);
  if (parsed == null) return null;

  if (parsed.hasScheme) {
    if (parsed.scheme == 'http' ||
        parsed.scheme == 'https' ||
        parsed.scheme == 'data') {
      // Loading an HTTP image from the HTTPS web application is blocked by
      // browsers as mixed content. Image hosts used by the application support
      // HTTPS, so use it consistently.
      if (parsed.scheme == 'http') {
        return parsed.replace(scheme: 'https').toString();
      }
      return parsed.toString();
    }
    return null;
  }

  final apiBaseUrl = Uri.parse(AppConfig.baseUrl);
  return apiBaseUrl.resolveUri(parsed).toString();
}

String _removeWrappingQuotes(String value) {
  if (value.length < 2) return value;

  final first = value[0];
  final last = value[value.length - 1];
  if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
    return value.substring(1, value.length - 1).trim();
  }
  return value;
}
