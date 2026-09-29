import '../../../../core/storage/session_store.dart';

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.needsProfile = true,
    this.user,
  });

  final String accessToken;
  final String refreshToken;

  /// Access token lifetime in seconds.
  final int expiresIn;

  /// True until the user has a name; the app then shows "A few details"
  /// instead of Home. Sent as `isNewUser` by verify-email and as
  /// `needsProfile` by login.
  final bool needsProfile;

  final AppUser? user;

  /// Parses the `data` object of `POST /api/auth/verify-email` and
  /// `POST /api/auth/login`.
  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 3600,
    needsProfile: (json['needsProfile'] ?? json['isNewUser']) as bool? ?? true,
    user: json['user'] is Map<String, dynamic>
        ? AppUser.fromJson(json['user'] as Map<String, dynamic>)
        : null,
  );
}

/// Why `verify-email` rejected the code.
enum OtpFailure {
  /// Wrong code; the user can retry.
  invalidCode,

  /// Code expired or already used; a new code is needed.
  expired,

  /// 5 wrong attempts used up this code; a new code is needed.
  tooManyAttempts,

  /// Account disabled; don't retry.
  suspended,

  /// Network, validation or server error.
  other,
}

/// `resend-otp` failed. [retryAfterSeconds] is set when the server's
/// cooldown hasn't elapsed (429).
class ResendOtpException implements Exception {
  const ResendOtpException(this.message, {this.retryAfterSeconds});

  final String message;
  final int? retryAfterSeconds;

  @override
  String toString() => message;
}

class OtpVerificationException implements Exception {
  const OtpVerificationException(this.failure, this.message);

  final OtpFailure failure;
  final String message;

  @override
  String toString() => message;
}
