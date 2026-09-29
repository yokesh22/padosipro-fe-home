import '../../../../core/storage/session_store.dart';

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.isNewUser,
  });

  final String accessToken;
  final String refreshToken;
  final AppUser user;

  /// New users complete the "A few details" step; returning users go Home.
  final bool isNewUser;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    isNewUser: json['isNewUser'] as bool? ?? true,
  );
}
