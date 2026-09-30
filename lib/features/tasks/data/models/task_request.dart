class TaskRequest {
  const TaskRequest({
    required this.id,
    required this.category,
    this.helpType,
    this.service,
    required this.status,
  });

  final String id;
  final String category;
  final String? helpType;
  final String? service;
  final String status;

  factory TaskRequest.fromJson(Map<String, dynamic> json) => TaskRequest(
    id: json['id']?.toString() ?? '',
    category: json['category'] as String? ?? '',
    helpType: json['helpType'] as String?,
    service: json['service'] as String?,
    status: json['status'] as String? ?? 'pending',
  );
}
