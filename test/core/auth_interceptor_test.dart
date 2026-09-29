import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padosipro/core/network/api_client.dart';
import 'package:padosipro/core/network/api_endpoints.dart';
import 'package:padosipro/core/storage/session_store.dart';

/// Fake backend: `/api/tasks` accepts only the current access token;
/// `/api/auth/refresh` rotates `r1` → `r2` like the real server.
class _FakeBackend implements HttpClientAdapter {
  int refreshStatus = 200;
  int refreshCalls = 0;
  String validAccessToken = 'new';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == ApiEndpoints.refresh) {
      refreshCalls++;
      final body = options.data as Map<String, dynamic>;
      if (refreshStatus != 200) return _json(refreshStatus, {'message': 'x'});
      if (body['refreshToken'] != 'r1') return _json(401, {'message': 'x'});
      return _json(200, {
        'data': {'accessToken': 'new', 'refreshToken': 'r2'},
      });
    }
    final ok = options.headers['Authorization'] == 'Bearer $validAccessToken';
    return ok ? _json(200, {'data': 'ok'}) : _json(401, {'message': 'x'});
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  late ProviderContainer container;
  late Dio dio;
  late _FakeBackend backend;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(sessionProvider.notifier)
        .start(
          const Session(
            accessToken: 'old',
            refreshToken: 'r1',
            user: AppUser(id: 'u1', phone: '', email: 'a@b.com'),
            needsProfile: false,
          ),
        );
    backend = _FakeBackend();
    dio = container.read(apiClientProvider)..httpClientAdapter = backend;
  });

  Session? session() => container.read(sessionProvider);

  test('a 401 refreshes, saves the rotated tokens and retries', () async {
    final res = await dio.get<dynamic>(ApiEndpoints.tasks);

    expect(res.statusCode, 200);
    expect(backend.refreshCalls, 1);
    expect(session()?.accessToken, 'new');
    expect(session()?.refreshToken, 'r2');
  });

  test('parallel 401s share one refresh', () async {
    await Future.wait([
      dio.get<dynamic>(ApiEndpoints.tasks),
      dio.get<dynamic>(ApiEndpoints.tasks),
      dio.get<dynamic>(ApiEndpoints.tasks),
    ]);

    expect(backend.refreshCalls, 1);
    expect(session()?.refreshToken, 'r2');
  });

  test('a rejected refresh token signs out', () async {
    backend.refreshStatus = 401;

    await expectLater(
      dio.get<dynamic>(ApiEndpoints.tasks),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(session(), isNull);
  });

  test('a server error during refresh keeps the session', () async {
    backend.refreshStatus = 500;

    await expectLater(
      dio.get<dynamic>(ApiEndpoints.tasks),
      throwsA(isA<DioException>()),
    );
    expect(session()?.refreshToken, 'r1');
  });

  test('a retried request that is rejected again does not loop', () async {
    backend.validAccessToken = 'never';

    await expectLater(
      dio.get<dynamic>(ApiEndpoints.tasks),
      throwsA(isA<DioException>()),
    );
    expect(backend.refreshCalls, 1);
  });
}
