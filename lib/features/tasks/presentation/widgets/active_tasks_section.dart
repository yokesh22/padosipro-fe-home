import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/routes.dart';
import '../../data/models/task_request.dart';
import '../providers/active_tasks_provider.dart';
import 'task_widgets.dart';

/// "Your requests" on Home: the user's open requests. Takes no space while
/// loading or when there are none.
class ActiveTasksSection extends ConsumerWidget {
  const ActiveTasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(activeTasksProvider);
    final headingStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontSize: 19);

    final Widget body;
    switch (tasks) {
      case AsyncData(:final value) when value.isNotEmpty:
        body = Column(
          children: [
            for (var i = 0; i < value.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _TaskCard(task: value[i]),
            ],
          ],
        );
      case AsyncError():
        body = Row(
          children: [
            const Expanded(
              child: Text(
                "Couldn't load your requests.",
                style: TextStyle(fontSize: 13.5, color: AppColors.muted),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(activeTasksProvider),
              child: const Text('Retry'),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your requests', style: headingStyle),
          const SizedBox(height: 14),
          body,
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final TaskRequest task;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      task.category,
      ?taskTimingLabel(task),
    ].where((s) => s.isNotEmpty).join(' · ');

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.requestPath(task.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(taskIcon(task), size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.service ?? task.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TaskStatusChip(status: task.status),
            ],
          ),
        ),
      ),
    );
  }
}
