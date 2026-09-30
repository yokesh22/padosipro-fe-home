import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/request_timing.dart';
import '../providers/service_request_draft.dart';
import '../widgets/request_flow_widgets.dart';

/// Request flow step 2: how soon, and for Scheduled a day and time window.
class RequestWhenScreen extends ConsumerWidget {
  const RequestWhenScreen({super.key});

  static const _options = [
    (
      timing: RequestTiming.standard,
      icon: Icons.calendar_today_outlined,
      subtitle: 'Within a few days is fine',
    ),
    (
      timing: RequestTiming.sameDay,
      icon: Icons.wb_sunny_outlined,
      subtitle: 'Today if possible',
    ),
    (
      timing: RequestTiming.express,
      icon: Icons.bolt,
      subtitle: 'As soon as you can',
    ),
    (
      timing: RequestTiming.scheduled,
      icon: Icons.schedule,
      subtitle: 'I have a specific time',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(serviceRequestDraftProvider);
    final notifier = ref.read(serviceRequestDraftProvider.notifier);

    Future<void> next() async {
      if (!draft.isTimingComplete) return;
      final sent = await context.push<String>(Routes.requestDetails);
      if (sent != null && context.mounted) context.pop(sent);
    }

    return RequestFlowPage(
      title: 'When do you need this?',
      subtitle: 'Pick what feels closest. You can always add detail next.',
      footer: PrimaryButton(
        label: 'Next',
        enabled: draft.isTimingComplete,
        onPressed: next,
      ),
      children: [
        for (final option in _options)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TimingCard(
              icon: option.icon,
              title: option.timing.label,
              subtitle: option.subtitle,
              selected: draft.timing == option.timing,
              onTap: () => notifier.setTiming(option.timing),
              expanded:
                  option.timing == RequestTiming.scheduled &&
                      draft.timing == RequestTiming.scheduled
                  ? _SchedulePicker(
                      day: draft.day,
                      slot: draft.slot,
                      onDay: notifier.setDay,
                      onSlot: notifier.setSlot,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

class _TimingCard extends StatelessWidget {
  const _TimingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.expanded,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// Extra content shown under the header while selected.
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: flowCardDecoration(selected: selected),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: selected ? AppColors.primary : AppColors.muted,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _Radio(selected: selected),
                  ],
                ),
                if (expanded != null) ...[
                  const SizedBox(height: 18),
                  expanded!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 6.5 : 1.5,
        ),
      ),
    );
  }
}

class _SchedulePicker extends StatelessWidget {
  const _SchedulePicker({
    required this.day,
    required this.slot,
    required this.onDay,
    required this.onSlot,
  });

  final DateTime? day;
  final TimeSlot? slot;
  final ValueChanged<DateTime> onDay;
  final ValueChanged<TimeSlot> onSlot;

  @override
  Widget build(BuildContext context) {
    final start = today();
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(start.year, start.month, start.day + i),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FlowSectionLabel('DAY'),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < days.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _DayChip(
                  weekday: i == 0 ? 'Today' : weekdayShort(days[i]),
                  date: days[i].day,
                  selected: days[i] == day,
                  onTap: () => onDay(days[i]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        const FlowSectionLabel('TIME WINDOW'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in TimeSlot.values)
              FlowPill(
                label: '${s.label} · ${s.hours}',
                selected: s == slot,
                onTap: () => onSlot(s),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.weekday,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final String weekday;
  final int date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    );
    final color = selected ? Colors.white : AppColors.ink;

    return Semantics(
      selected: selected,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: SizedBox(
            width: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
