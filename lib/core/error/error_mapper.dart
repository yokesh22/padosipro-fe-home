import 'package:dio/dio.dart';

import 'app_exception.dart';

abstract final class ErrorMapper {
  static const _generic = 'Something went wrong. Please try again.';

  static AppException fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException('The request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const AppException(
          'Unable to reach the server. Check your connection.',
        );
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        // Backend errors: `{success, statusCode, message, error: {code}}`.
        final data = e.response?.data;
        final body = data is Map ? data : const {};
        final error = body['error'];
        final code = error is Map ? error['code'] : null;
        final details = error is Map ? error['details'] : null;
        final message =
            body['message'] ?? (error is Map ? error['message'] : null);
        return AppException(
          // Server-side failures aren't meaningful to the user.
          message is String && message.isNotEmpty && (status ?? 0) < 500
              ? message
              : _generic,
          statusCode: status,
          code: code is String ? code : null,
          details: details is Map
              ? Map<String, dynamic>.from(details)
              : const {},
        );
      default:
        return const AppException(_generic);
    }
  }

  static AppException from(Object error) => switch (error) {
    AppException() => error,
    DioException() => fromDio(error),
    _ => const AppException(_generic),
  };
}
