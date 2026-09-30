import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padosipro/features/tasks/data/models/request_timing.dart';
import 'package:padosipro/features/tasks/data/models/task_request.dart';
import 'package:padosipro/features/tasks/data/tasks_repository.dart';

/// Replies to `POST` and `GET /api/tasks` with the backend's `{success, data}` envelope
/// and records the request body.
class _FakeBackend implements HttpClientAdapter {
  Map<String, dynamic>? sentBody;
  Map<String, dynamic>? query;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'GET') {
      query = options.queryParameters;
      return _json(200, {
        'success': true,
        'data': {
          'items': [
            {
              'id': 't2',
              'category': 'Home Repairs',
              'helpType': 'Appliances',
              'service': 'AC service & repair',
              'timing': 'scheduled',
              'day': '2026-10-03',
              'slot': 'evening',
              'details': 'AC is leaking',
              'status': 'in_progress',
              'createdAt': '2026-10-01T09:30:00.000Z',
            },
            {
              'id': 't1',
              'category': 'Home Services',
              'timing': 'same_day',
              'day': null,
              'slot': null,
              'status': 'pending',
            },
          ],
          'nextCursor': null,
        },
      });
    }
    sentBody = options.data as Map<String, dynamic>;
    return _json(201, {
      'success': true,
      'data': {'id': 't1', ...sentBody!, 'status': 'pending'},
    });
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
  test(
    'createTaskRequest parses the task from the response envelope',
    () async {
      final backend = _FakeBackend();
      final repo = TasksRepository(Dio()..httpClientAdapter = backend);

      final task = await repo.createTaskRequest(
        category: 'Home Repairs',
        helpType: 'Appliances',
        service: 'AC service & repair',
        timing: RequestTiming.scheduled,
        day: DateTime(2026, 10, 3),
        slot: TimeSlot.morning,
        details: 'AC is leaking',
      );

      expect(task.id, 't1');
      expect(task.category, 'Home Repairs');
      expect(task.helpType, 'Appliances');
      expect(task.service, 'AC service & repair');
      expect(task.status, TaskStatus.pending);
      expect(backend.sentBody, {
        'category': 'Home Repairs',
        'helpType': 'Appliances',
        'service': 'AC service & repair',
        'timing': 'scheduled',
        'day': '2026-10-03',
        'slot': 'morning',
        'details': 'AC is leaking',
      });
    },
  );

  test('getActiveTasks asks for active tasks and parses the items', () async {
    final backend = _FakeBackend();
    final repo = TasksRepository(Dio()..httpClientAdapter = backend);

    final tasks = await repo.getActiveTasks();

    expect(backend.query, {'status': 'active', 'limit': 5});
    expect(tasks, hasLength(2));
    final first = tasks.first;
    expect(first.id, 't2');
    expect(first.service, 'AC service & repair');
    expect(first.timing, RequestTiming.scheduled);
    expect(first.day, DateTime(2026, 10, 3));
    expect(first.slot, TimeSlot.evening);
    expect(first.status, TaskStatus.inProgress);
    expect(first.createdAt, DateTime.utc(2026, 10, 1, 9, 30).toLocal());
    expect(tasks.last.timing, RequestTiming.sameDay);
    expect(tasks.last.day, isNull);
    expect(tasks.last.slot, isNull);
  });
}
