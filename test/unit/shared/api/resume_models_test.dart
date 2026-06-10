import 'package:flutter_test/flutter_test.dart';
import 'package:Collab/shared/api/client.dart';
import 'package:Collab/shared/api/resume_models.dart';

void main() {
  group('Resume models parsing', () {
    test('ResumeUploadResult parses upload response', () {
      final result = ResumeUploadResult.fromJson({
        'has_resume': true,
        'resume_filename': 'my_resume.pdf',
        'resume_uploaded_at': '2026-06-09T12:00:00',
      });

      expect(result.hasResume, isTrue);
      expect(result.resumeFilename, 'my_resume.pdf');
      expect(result.resumeUploadedAt, DateTime.parse('2026-06-09T12:00:00'));
    });

    test('ResumeDownloadResult parses download response', () {
      final result = ResumeDownloadResult.fromJson({
        'download_url': 'https://storage.googleapis.com/resume.pdf',
        'resume_filename': 'my_resume.pdf',
        'expires_in_seconds': 3600,
      });

      expect(result.downloadUrl, contains('storage.googleapis.com'));
      expect(result.resumeFilename, 'my_resume.pdf');
      expect(result.expiresInSeconds, 3600);
    });

    test('ResumeDeleteResult parses delete response', () {
      final result = ResumeDeleteResult.fromJson({'deleted': true});
      expect(result.deleted, isTrue);
    });

    test('ApiResponse parses resume upload envelope', () {
      final response = ApiResponse<ResumeUploadResult>.fromJson(
        {
          'success': true,
          'data': {
            'has_resume': true,
            'resume_filename': 'cv.docx',
            'resume_uploaded_at': '2026-06-09T15:30:00',
          },
          'error': null,
        },
        (data) => ResumeUploadResult.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isTrue);
      expect(response.data?.resumeFilename, 'cv.docx');
      expect(response.error, isNull);
    });

    test('ApiResponse parses resume error envelope', () {
      final response = ApiResponse<ResumeUploadResult>.fromJson(
        {
          'success': false,
          'data': null,
          'error': 'Resume file must be 5 MB or smaller',
        },
        (data) => ResumeUploadResult.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isFalse);
      expect(response.data, isNull);
      expect(response.error, 'Resume file must be 5 MB or smaller');
    });
  });
}
