import 'package:flutter_test/flutter_test.dart';

import 'package:Collab/shared/utils/image_url_utils.dart';

void main() {
  group('resolveImageUrl', () {
    test('keeps secure absolute URLs', () {
      expect(
        resolveImageUrl('https://cdn.example.com/logo.png?version=2'),
        'https://cdn.example.com/logo.png?version=2',
      );
    });

    test('upgrades HTTP URLs to HTTPS for web compatibility', () {
      expect(
        resolveImageUrl('http://cdn.example.com/logo.png'),
        'https://cdn.example.com/logo.png',
      );
    });

    test('resolves API-relative image paths against the API host', () {
      expect(
        resolveImageUrl('/uploads/company-logo.png'),
        'https://collab-api-810993564533.europe-north2.run.app/uploads/company-logo.png',
      );
    });

    test('returns null for missing or unsupported values', () {
      expect(resolveImageUrl('  '), isNull);
      expect(resolveImageUrl('gs://bucket/logo.png'), isNull);
    });
  });
}
