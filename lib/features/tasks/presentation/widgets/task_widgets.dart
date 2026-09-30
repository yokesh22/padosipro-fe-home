import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/service_catalog.dart';
import '../../data/models/request_timing.dart';
import '../../data/models/task_request.dart';
import '../providers/service_request_draft.dart';

/// The catalog icon for [task]'s category.
IconData taskIcon(TaskRequest task) {
  for (final c in ServiceCatalog.categories) {
    if (c.label == task.category) return c.icon;
  }
  return Icons.task_alt;
}

/// e.g. "Same day" or "Tomorrow, Morning"; null for an unknown timing.
String? taskTimingLabel(TaskRequest task) {
  final timing = task.timing;
  if (timing == null) return null;
  final day = task.day;
  final slot = task.slot;
  if (timing != RequestTiming.scheduled || day == null || slot == null) {
    return timing.label;
  }
  return '${dayLabel(day)}, ${slot.label}';
}

class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, ink, border) = switch (status) {
      TaskStatus.pending => (
        AppColors.soonBg,
        AppColors.soonInk,
        AppColors.soonBorder,
      ),
      TaskStatus.assigned || TaskStatus.inProgress => (
        AppColors.mint,
        AppColors.primary,
        AppColors.mintBorder,
      ),
      TaskStatus.completed => (
        AppColors.selectedBg,
        AppColors.success,
        AppColors.mintBorder,
      ),
      TaskStatus.cancelled => (
        AppColors.divider,
        AppColors.muted,
        AppColors.border,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink),
      ),
    );
  }
}
