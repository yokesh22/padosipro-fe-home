/// How soon the user needs a request handled.
enum RequestTiming {
  standard('Standard', 'standard'),
  sameDay('Same day', 'same_day'),
  express('Express', 'express'),
  scheduled('Scheduled', 'scheduled');

  const RequestTiming(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

/// Time window for a [RequestTiming.scheduled] request.
enum TimeSlot {
  morning('Morning', '8–12'),
  afternoon('Afternoon', '12–4'),
  evening('Evening', '4–8');

  const TimeSlot(this.label, this.hours);

  final String label;
  final String hours;

  String get apiValue => name;
}
