import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Collab/shared/utils/help_request_utils.dart';

void main() {
  group('HelpRequestUtils', () {
    test('detects pending help request error', () {
      expect(
        HelpRequestUtils.isPendingHelpRequestError(
          'You already have a pending help request. Please wait until an admin resolves it before submitting a new one.',
        ),
        isTrue,
      );
    });

    test('returns pending message for HelpRequestException', () {
      const error = HelpRequestException(
        'You already have a pending help request.',
      );

      expect(
        HelpRequestUtils.messageFor(error),
        HelpRequestUtils.pendingMessage,
      );
    });

    test('extracts error from DioException response body', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/request-help'),
        response: Response(
          requestOptions: RequestOptions(path: '/request-help'),
          data: {
            'success': false,
            'error':
                'You already have a pending help request. Please wait until an admin resolves it before submitting a new one.',
          },
        ),
      );

      expect(HelpRequestUtils.shouldShowDialog(error), isTrue);
      expect(
        HelpRequestUtils.messageFor(error),
        HelpRequestUtils.pendingMessage,
      );
    });
  });
}
