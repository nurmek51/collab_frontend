import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../state/auth.dart';

class FreelancerPortfolioStorageService {
  final FirebaseStorage _storage;
  final AuthStore _authStore;

  FreelancerPortfolioStorageService(this._storage, this._authStore);

  Future<String> uploadPortfolioFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final freelancerId = await _authStore.getUserId();
    if (freelancerId == null || freelancerId.isEmpty) {
      throw Exception('Не удалось определить freelancerId для загрузки файла.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedName = fileName.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );

    final extension = sanitizedName.contains('.')
        ? sanitizedName.split('.').last.toLowerCase()
        : '';

    final ref = _storage.ref().child(
      'freelancers/$freelancerId/portfolio/$timestamp-$sanitizedName',
    );

    final metadata = SettableMetadata(
      contentType: _contentType(extension),
      customMetadata: {
        'freelancerId': freelancerId,
        'originalFileName': fileName,
      },
    );

    final snapshot = await ref.putData(fileBytes, metadata);
    return snapshot.ref.getDownloadURL();
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }
}
