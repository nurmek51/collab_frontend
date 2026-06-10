import 'package:http_parser/http_parser.dart';

const int kMaxResumeFileSizeBytes = 5 * 1024 * 1024;
const List<String> kAllowedResumeExtensions = ['pdf', 'doc', 'docx'];

MediaType? mimeTypeForResumeFile(String fileName) {
  final ext = _extension(fileName);
  switch (ext) {
    case 'pdf':
      return MediaType('application', 'pdf');
    case 'doc':
      return MediaType('application', 'msword');
    case 'docx':
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    default:
      return null;
  }
}

bool isAllowedResumeExtension(String fileName) {
  return kAllowedResumeExtensions.contains(_extension(fileName));
}

String? validateResumeFile({required String fileName, required int fileSize}) {
  if (!isAllowedResumeExtension(fileName)) {
    return 'Допустимы только файлы PDF, DOC и DOCX';
  }
  if (fileSize > kMaxResumeFileSizeBytes) {
    return 'Размер файла не должен превышать 5 МБ';
  }
  return null;
}

String _extension(String fileName) {
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == fileName.length - 1) {
    return '';
  }
  return fileName.substring(dotIndex + 1).toLowerCase();
}
