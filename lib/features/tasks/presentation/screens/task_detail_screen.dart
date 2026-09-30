import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../shared/widgets/back_text_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/task_request.dart';
import '../providers/task_detail_notifier.dart';
import '../widgets/task_widgets.dart';

/// One request: what was asked, when, its status, and Cancel while the LM
/// hasn't started on it.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: const Text('Your Lifestyle Manager will stop working on it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(cancelTaskProvider.notifier).cancel(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(cancelTaskProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });
    final task = ref.watch(taskDetailProvider(id));
    final isCancelling = ref.watch(cancelTaskProvider).isLoading;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    final canCancel = switch (task) {
      AsyncData(:final value) =>
        value.status == TaskStatus.pending ||
            value.status == TaskStatus.assigned,
      _ => false,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: BackTextButton(onPressed: () => context.pop()),
              ),
            ),
            Expanded(
              child: switch (task) {
                AsyncData(:final value) => _TaskBody(task: value),
                AsyncError(:final error) => _ErrorBody(
                  error: error,
                  onRetry: () => ref.invalidate(taskDetailProvider(id)),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
            if (canCancel)
              Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
                child: SizedBox(
                  height: AppSizes.buttonHeight,
                  child: OutlinedButton(
                    onPressed: isCancelling
                        ? null
                        : () => _cancel(context, ref),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.signOutBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      isCancelling ? 'Cancelling…' : 'Cancel request',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskBody extends StatelessWidget {
  const _TaskBody({required this.task});

  final TaskRequest task;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final timing = taskTimingLabel(task);
    final kind = [
      task.category,
      ?task.helpType,
    ].where((s) => s.isNotEmpty).join(' · ');
    final details = task.details?.trim() ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(taskIcon(task), color: AppColors.primary),
            ),
            const Spacer(),
            TaskStatusChip(status: task.status),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          task.service ?? task.category,
          style: textTheme.headlineLarge?.copyWith(fontSize: 27),
        ),
        if (kind.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(kind, style: textTheme.bodyMedium),
        ],
        const SizedBox(height: 24),
        if (timing != null) _Field(label: 'WHEN', value: timing),
        if (details.isNotEmpty) _Field(label: 'DETAILS', value: details),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 15.5, height: 1.45)),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final notFound =
        error is AppException &&
        (error as AppException).code == 'TASK_NOT_FOUND';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            notFound ? "This request couldn't be found." : error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          notFound
              ? PrimaryButton(label: 'Go back', onPressed: () => context.pop())
              : PrimaryButton(label: 'Try again', onPressed: onRetry),
        ],
      ),
    );
  }
}
