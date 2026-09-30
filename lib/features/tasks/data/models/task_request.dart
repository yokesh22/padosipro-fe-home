import 'request_timing.dart';

/// Where a request is in its lifecycle.
enum TaskStatus {
  pending('Requested', 'pending'),
  assigned('LM assigned', 'assigned'),
  inProgress('In progress', 'in_progress'),
  completed('Done', 'completed'),
  cancelled('Cancelled', 'cancelled');

  const TaskStatus(this.label, this.apiValue);

  final String label;
  final String apiValue;

  static TaskStatus fromApi(String? value) => values.firstWhere(
    (s) => s.apiValue == value,
    orElse: () => TaskStatus.pending,
  );
}

class TaskRequest {
  const TaskRequest({
    required this.id,
    required this.category,
    this.helpType,
    this.service,
    this.timing,
    this.day,
    this.slot,
    this.details,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String category;
  final String? helpType;
  final String? service;
  final RequestTiming? timing;

  /// Only for [RequestTiming.scheduled]; a local date at midnight.
  final DateTime? day;
  final TimeSlot? slot;
  final String? details;
  final TaskStatus status;
  final DateTime? createdAt;

  factory TaskRequest.fromJson(Map<String, dynamic> json) => TaskRequest(
    id: json['id']?.toString() ?? '',
    category: json['category'] as String? ?? '',
    helpType: json['helpType'] as String?,
    service: json['service'] as String?,
    timing: _byApiValue(
      RequestTiming.values,
      json['timing'],
      (t) => t.apiValue,
    ),
    // `yyyy-MM-dd` with no offset parses as a local date.
    day: DateTime.tryParse(json['day'] as String? ?? ''),
    slot: _byApiValue(TimeSlot.values, json['slot'], (s) => s.apiValue),
    details: json['details'] as String?,
    status: TaskStatus.fromApi(json['status'] as String?),
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal(),
  );

  static T? _byApiValue<T>(
    List<T> values,
    Object? value,
    String Function(T) apiValue,
  ) {
    for (final v in values) {
      if (apiValue(v) == value) return v;
    }
    return null;
  }
}
