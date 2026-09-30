import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/service_catalog.dart';
import '../../data/models/request_timing.dart';

/// Selections made across All services → When → Tell us more.
class ServiceRequestDraft {
  const ServiceRequestDraft({
    this.categoryIndex,
    this.helpTypeIndex = 0,
    this.service,
    this.timing,
    this.day,
    this.slot,
    this.details = '',
  });

  final int? categoryIndex;
  final int helpTypeIndex;
  final String? service;
  final RequestTiming? timing;

  /// Date only (midnight). Kept when switching away from Scheduled so it's
  /// still there if the user switches back.
  final DateTime? day;
  final TimeSlot? slot;
  final String details;

  ServiceCategory? get category =>
      categoryIndex == null ? null : ServiceCatalog.categories[categoryIndex!];

  HelpType? get helpType => category?.helpTypes[helpTypeIndex];

  Partner? get partner =>
      service == null ? null : ServiceCatalog.partnerFor(service!);

  bool get isTimingComplete => switch (timing) {
    null => false,
    RequestTiming.scheduled => day != null && slot != null,
    _ => true,
  };

  bool get canSend =>
      service != null && isTimingComplete && details.trim().isNotEmpty;

  /// e.g. "Same day" or "Tomorrow, Morning".
  String? get timingLabel {
    final t = timing;
    if (t == null) return null;
    if (t != RequestTiming.scheduled || day == null || slot == null) {
      return t.label;
    }
    return '${dayLabel(day!)}, ${slot!.label}';
  }

  ServiceRequestDraft _copy({
    int? helpTypeIndex,
    String? Function()? service,
    RequestTiming? timing,
    DateTime? day,
    TimeSlot? slot,
    String? details,
  }) => ServiceRequestDraft(
    categoryIndex: categoryIndex,
    helpTypeIndex: helpTypeIndex ?? this.helpTypeIndex,
    service: service == null ? this.service : service(),
    timing: timing ?? this.timing,
    day: day ?? this.day,
    slot: slot ?? this.slot,
    details: details ?? this.details,
  );
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// "Mon", "Tue", …
String weekdayShort(DateTime day) => _weekdays[day.weekday - 1];

/// "Today", "Tomorrow", or e.g. "Fri 3 Oct".
String dayLabel(DateTime day) {
  final start = today();
  if (day == start) return 'Today';
  if (day == DateTime(start.year, start.month, start.day + 1)) {
    return 'Tomorrow';
  }
  return '${weekdayShort(day)} ${day.day} ${_months[day.month - 1]}';
}

class ServiceRequestDraftNotifier extends Notifier<ServiceRequestDraft> {
  @override
  ServiceRequestDraft build() => const ServiceRequestDraft();

  /// Opens a category with its first help type and no service.
  void selectCategory(int index) {
    if (state.categoryIndex == index) return;
    final s = state;
    state = ServiceRequestDraft(
      categoryIndex: index,
      timing: s.timing,
      day: s.day,
      slot: s.slot,
      details: s.details,
    );
  }

  /// Changing the help type clears the chosen service.
  void selectHelpType(int index) {
    if (state.helpTypeIndex == index) return;
    state = state._copy(helpTypeIndex: index, service: () => null);
  }

  /// Tapping the chosen service again deselects it.
  void toggleService(String service) {
    state = state._copy(
      service: () => state.service == service ? null : service,
    );
  }

  void setTiming(RequestTiming timing) => state = state._copy(timing: timing);

  void setDay(DateTime day) => state = state._copy(day: day);

  void setSlot(TimeSlot slot) => state = state._copy(slot: slot);

  void setDetails(String details) => state = state._copy(details: details);
}

/// Auto-disposed, so the flow starts fresh each time All services opens
/// and resets once its screens are gone.
final serviceRequestDraftProvider =
    NotifierProvider.autoDispose<
      ServiceRequestDraftNotifier,
      ServiceRequestDraft
    >(ServiceRequestDraftNotifier.new);
