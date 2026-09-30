import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../data/models/task_request.dart';
import '../../data/tasks_repository.dart';
import 'active_tasks_provider.dart';

/// One request, by id.
class TaskDetailNotifier extends AsyncNotifier<TaskRequest> {
  TaskDetailNotifier(this.id);

  final String id;

  @override
  FutureOr<TaskRequest> build() =>
      ref.read(tasksRepositoryProvider).getTask(id);

  /// Shows [task] as returned by the server (e.g. after cancelling).
  void replace(TaskRequest task) => state = AsyncData(task);
}

final taskDetailProvider = AsyncNotifierProvider.autoDispose
    .family<TaskDetailNotifier, TaskRequest, String>(TaskDetailNotifier.new);

class CancelTaskNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Cancels request [id]. Returns whether it was cancelled; on failure the
  /// error is in [state].
  Future<bool> cancel(String id) async {
    state = const AsyncLoading();
    try {
      final task = await ref.read(tasksRepositoryProvider).cancelTask(id);
      if (!ref.mounted) return false;
      ref.read(taskDetailProvider(id).notifier).replace(task);
      ref.invalidate(activeTasksProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      if (!ref.mounted) return false;
      // The LM moved it on since the screen loaded: show where it is now.
      if (e is AppException && e.code == 'TASK_NOT_CANCELLABLE') {
        ref.invalidate(taskDetailProvider(id));
        ref.invalidate(activeTasksProvider);
      }
      state = AsyncError(e, st);
      return false;
    }
  }
}

final cancelTaskProvider =
    AsyncNotifierProvider.autoDispose<CancelTaskNotifier, void>(
      CancelTaskNotifier.new,
    );
