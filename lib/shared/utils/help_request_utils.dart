import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HelpRequestException implements Exception {
  final String rawError;

  const HelpRequestException(this.rawError);

  bool get isPendingHelpRequest =>
      HelpRequestUtils.isPendingHelpRequestError(rawError);

  @override
  String toString() => rawError;
}

abstract final class HelpRequestUtils {
  static const pendingMessage =
      'У вас уже есть открытый запрос, дождитесь ответа администратора.';

  static bool isPendingHelpRequestError(String? text) {
    return text?.toLowerCase().contains('pending help request') ?? false;
  }

  static String? rawErrorMessage(Object error) {
    if (error is HelpRequestException) {
      return error.rawError;
    }

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final apiError = data['error']?.toString();
        if (apiError != null && apiError.isNotEmpty) {
          return apiError;
        }
      }
    }

    return error.toString();
  }

  static String messageFor(Object error) {
    final raw = rawErrorMessage(error);
    if (isPendingHelpRequestError(raw)) {
      return pendingMessage;
    }

    if (error is HelpRequestException && error.rawError.isNotEmpty) {
      return error.rawError;
    }

    return 'Не удалось отправить запрос. Попробуйте позже.';
  }

  static bool shouldShowDialog(Object error) {
    return isPendingHelpRequestError(rawErrorMessage(error));
  }

  static Future<void> showErrorDialog(
    BuildContext context,
    Object error,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Запрос на звонок',
          style: TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w600),
        ),
        content: Text(
          messageFor(error),
          style: const TextStyle(fontFamily: 'Ubuntu', fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}
