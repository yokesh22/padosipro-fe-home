import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_request.dart';
import '../../data/tasks_repository.dart';

class CreateTaskNotifier extends AsyncNotifier<TaskRequest?> {
  @override
  Future<TaskRequest?> build() async => null;

  /// Returns the created request, or null on failure.
  Future<TaskRequest?> submit({
    required String category,
    String? subType,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard<TaskRequest?>(
      () => ref
          .read(tasksRepositoryProvider)
          .createTaskRequest(category: category, subType: subType),
    );
    if (!ref.mounted) return null;
    state = result;
    return result.value;
  }
}

final createTaskProvider =
    AsyncNotifierProvider.autoDispose<CreateTaskNotifier, TaskRequest?>(
      CreateTaskNotifier.new,
    );
