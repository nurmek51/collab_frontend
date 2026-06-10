import 'package:http_parser/http_parser.dart';

const int kMaxAvatarFileSizeBytes = 2 * 1024 * 1024;
const List<String> kAllowedAvatarExtensions = ['jpg', 'jpeg', 'png', 'webp'];

MediaType? mimeTypeForAvatarFile(String fileName) {
  switch (_extension(fileName)) {
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');
    case 'png':
      return MediaType('image', 'png');
    case 'webp':
      return MediaType('image', 'webp');
    default:
      return null;
  }
}

bool isAllowedAvatarExtension(String fileName) {
  return kAllowedAvatarExtensions.contains(_extension(fileName));
}

String? validateAvatarFile({required String fileName, required int fileSize}) {
  if (!isAllowedAvatarExtension(fileName)) {
    return 'Допустимы только JPEG, PNG и WebP';
  }
  if (fileSize > kMaxAvatarFileSizeBytes) {
    return 'Размер файла не должен превышать 2 МБ';
  }
  return null;
}

String initialsFromName({String? name, String? surname, String? fallback}) {
  final parts = <String>[
    if (name != null && name.trim().isNotEmpty) name.trim(),
    if (surname != null && surname.trim().isNotEmpty) surname.trim(),
  ];

  if (parts.isEmpty) {
    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback.trim()[0].toUpperCase();
    }
    return '?';
  }

  final initials = parts
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  return initials.isEmpty ? '?' : initials;
}

String _extension(String fileName) {
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == fileName.length - 1) {
    return '';
  }
  return fileName.substring(dotIndex + 1).toLowerCase();
}
