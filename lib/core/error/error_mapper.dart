import 'package:dio/dio.dart';

import 'app_exception.dart';

abstract final class ErrorMapper {
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
        final data = e.response?.data;
        final serverMessage = data is Map ? data['message'] : null;
        return AppException(
          serverMessage is String && serverMessage.isNotEmpty
              ? serverMessage
              : 'Something went wrong. Please try again.',
          statusCode: e.response?.statusCode,
        );
      default:
        return const AppException('Something went wrong. Please try again.');
    }
  }

  static AppException from(Object error) => switch (error) {
    AppException() => error,
    DioException() => fromDio(error),
    _ => const AppException('Something went wrong. Please try again.'),
  };
}
