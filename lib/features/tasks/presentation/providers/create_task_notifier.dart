import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_request.dart';
import '../../data/tasks_repository.dart';
import 'active_tasks_provider.dart';
import 'service_request_draft.dart';

class CreateTaskNotifier extends AsyncNotifier<TaskRequest?> {
  @override
  FutureOr<TaskRequest?> build() => null;

  /// Sends a complete [draft] ([ServiceRequestDraft.canSend]). Returns the
  /// created request, or null on failure.
  Future<TaskRequest?> submit(ServiceRequestDraft draft) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard<TaskRequest?>(
      () => ref
          .read(tasksRepositoryProvider)
          .createTaskRequest(
            category: draft.category!.label,
            helpType: draft.helpType!.label,
            service: draft.service!,
            timing: draft.timing!,
            day: draft.day,
            slot: draft.slot,
            details: draft.details.trim(),
          ),
    );
    if (!ref.mounted) return null;
    if (result.hasValue) ref.invalidate(activeTasksProvider);
    state = result;
    return result.value;
  }
}

final createTaskProvider =
    AsyncNotifierProvider.autoDispose<CreateTaskNotifier, TaskRequest?>(
      CreateTaskNotifier.new,
    );
