import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import 'models/request_timing.dart';
import 'models/task_request.dart';

final tasksRepositoryProvider = Provider<TasksRepository>(
  (ref) => TasksRepository(ref.watch(apiClientProvider)),
);

class TasksRepository {
  TasksRepository(this._dio);

  final Dio _dio;

  /// `POST /api/tasks`. [day] and [slot] are only sent for
  /// [RequestTiming.scheduled]; [day] as `yyyy-MM-dd`.
  Future<TaskRequest> createTaskRequest({
    required String category,
    required String helpType,
    required String service,
    required RequestTiming timing,
    DateTime? day,
    TimeSlot? slot,
    required String details,
  }) async {
    final scheduled = timing == RequestTiming.scheduled;
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.tasks,
        data: {
          'category': category,
          'helpType': helpType,
          'service': service,
          'timing': timing.apiValue,
          if (scheduled && day != null) 'day': _isoDate(day),
          if (scheduled && slot != null) 'slot': slot.apiValue,
          'details': details,
        },
      );
      return TaskRequest.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `GET /api/tasks?status=active`: the user's pending, assigned and
  /// in-progress requests, newest first.
  Future<List<TaskRequest>> getActiveTasks({int limit = 5}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.tasks,
        queryParameters: {'status': 'active', 'limit': limit},
      );
      final data = res.data!['data'] as Map<String, dynamic>;
      return [
        for (final item in data['items'] as List<dynamic>)
          TaskRequest.fromJson(item as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `GET /api/tasks/:id`. 404 `TASK_NOT_FOUND` if missing or not the user's.
  Future<TaskRequest> getTask(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.task(id));
      return TaskRequest.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// `PATCH /api/tasks/:id/cancel`. 409 `TASK_NOT_CANCELLABLE` once the task
  /// is past `assigned`.
  Future<TaskRequest> cancelTask(String id) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.cancelTask(id),
      );
      return TaskRequest.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
