import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import 'models/task_request.dart';

final tasksRepositoryProvider = Provider<TasksRepository>(
  (ref) => TasksRepository(ref.watch(apiClientProvider)),
);

class TasksRepository {
  TasksRepository(this._dio);

  final Dio _dio;

  Future<TaskRequest> createTaskRequest({
    required String category,
    String? subType,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.tasks,
        data: {'category': category, 'subType': ?subType},
      );
      return TaskRequest.fromJson(res.data!);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }
}
