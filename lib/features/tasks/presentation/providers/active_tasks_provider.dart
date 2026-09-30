import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_request.dart';
import '../../data/tasks_repository.dart';

/// The user's open requests, shown on Home. Invalidated when a request is
/// created so the list picks it up.
class ActiveTasksNotifier extends AsyncNotifier<List<TaskRequest>> {
  @override
  FutureOr<List<TaskRequest>> build() =>
      ref.read(tasksRepositoryProvider).getActiveTasks();
}

final activeTasksProvider =
    AsyncNotifierProvider.autoDispose<ActiveTasksNotifier, List<TaskRequest>>(
      ActiveTasksNotifier.new,
    );
