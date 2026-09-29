import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/session_store.dart';
import 'api_endpoints.dart';

/// Attaches the JWT and refreshes it once on a 401.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._ref, this._dio);

  final Ref _ref;
  final Dio _dio;

  static const _retriedKey = 'auth_retried';
  static const _skipAuthKey = 'skip_auth';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _ref.read(sessionProvider)?.accessToken;
    if (token != null && options.extra[_skipAuthKey] != true) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final session = _ref.read(sessionProvider);
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        session != null &&
        request.extra[_retriedKey] != true &&
        request.path != ApiEndpoints.refresh;

    if (!shouldRefresh) return handler.next(err);

    try {
      // Bare Dio so the refresh call doesn't re-enter this interceptor.
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final res = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refreshToken': session.refreshToken},
      );
      final data = res.data ?? const {};
      final accessToken = data['accessToken'] as String;
      _ref
          .read(sessionProvider.notifier)
          .updateTokens(
            accessToken: accessToken,
            refreshToken: data['refreshToken'] as String?,
          );

      request.extra[_retriedKey] = true;
      request.headers['Authorization'] = 'Bearer $accessToken';
      handler.resolve(await _dio.fetch<dynamic>(request));
    } catch (_) {
      _ref.read(sessionProvider.notifier).clear();
      handler.next(err);
    }
  }
}
