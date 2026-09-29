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

  /// Dio without this interceptor, for the refresh call and the retry.
  /// Errors are handled one at a time, so a call made through [_dio] from
  /// [onError] that fails would wait behind the error being handled
  /// forever. Shares the main client's adapter (connections), which the
  /// main client closes.
  late final _plainDio = Dio(
    BaseOptions(
      baseUrl: _dio.options.baseUrl,
      connectTimeout: _dio.options.connectTimeout,
      receiveTimeout: _dio.options.receiveTimeout,
      contentType: Headers.jsonContentType,
    ),
  )..httpClientAdapter = _dio.httpClientAdapter;

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
        request.extra[_skipAuthKey] != true &&
        request.path != ApiEndpoints.refresh;

    if (!shouldRefresh) return handler.next(err);
    request.extra[_retriedKey] = true;

    // Errors are handled one at a time, so another request may have already
    // refreshed while this one waited. Retry with that token: refreshing
    // again would rotate a token that's no longer needed.
    final sentHeader = request.headers['Authorization'];
    if (sentHeader != 'Bearer ${session.accessToken}') {
      return _retry(request, session.accessToken, err, handler);
    }

    final String accessToken;
    try {
      accessToken = await _refresh(session.refreshToken);
    } on DioException catch (e) {
      // The refresh token is expired, revoked or was reused: sign out. On
      // network or server errors keep the session so the user stays
      // signed in once the connection is back.
      final status = e.response?.statusCode;
      if (status == 400 || status == 401) {
        _ref.read(sessionProvider.notifier).clear();
      }
      return handler.next(err);
    } catch (_) {
      // Unexpected response shape; keep the session and fail this request.
      return handler.next(err);
    }
    return _retry(request, accessToken, err, handler);
  }

  /// `POST /api/auth/refresh`. The server rotates the refresh token, so the
  /// new one must be saved: the old one is now revoked, and presenting it
  /// again revokes the whole session. Returns the new access token.
  Future<String> _refresh(String refreshToken) async {
    final res = await _plainDio.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );
    // `{success, statusCode, message, data: {accessToken, refreshToken,
    // tokenType, expiresIn}}`
    final data = res.data!['data'] as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    _ref
        .read(sessionProvider.notifier)
        .updateTokens(
          accessToken: accessToken,
          refreshToken: data['refreshToken'] as String,
        );
    return accessToken;
  }

  Future<void> _retry(
    RequestOptions request,
    String accessToken,
    DioException original,
    ErrorInterceptorHandler handler,
  ) async {
    request.headers['Authorization'] = 'Bearer $accessToken';
    try {
      handler.resolve(await _plainDio.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(original);
    }
  }
}
