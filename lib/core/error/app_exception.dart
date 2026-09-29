class AppException implements Exception {
  const AppException(
    this.message, {
    this.statusCode,
    this.code,
    this.details = const {},
  });

  final String message;
  final int? statusCode;

  /// Backend error code, e.g. `BAD_REQUEST`.
  final String? code;

  /// Backend `error.details`, e.g. `{retryAfterSeconds: 18}`.
  final Map<String, dynamic> details;

  @override
  String toString() => message;
}
