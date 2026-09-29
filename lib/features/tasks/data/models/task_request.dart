class TaskRequest {
  const TaskRequest({
    required this.id,
    required this.category,
    this.subType,
    required this.status,
  });

  final String id;
  final String category;
  final String? subType;
  final String status;

  factory TaskRequest.fromJson(Map<String, dynamic> json) => TaskRequest(
    id: json['id']?.toString() ?? '',
    category: json['category'] as String? ?? '',
    subType: json['subType'] as String?,
    status: json['status'] as String? ?? 'pending',
  );
}
