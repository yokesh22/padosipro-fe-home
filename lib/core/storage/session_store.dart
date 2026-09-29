import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.phone,
    required this.email,
    this.name,
    this.address,
    this.society,
    this.flat,
    this.notes,
  });

  final String id;
  final String phone;
  final String email;
  final String? name;
  final String? address;
  final String? society;
  final String? flat;
  final String? notes;

  String get firstName {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? '' : trimmed.split(RegExp(r'\s+')).first;
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id']?.toString() ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    name: json['name'] as String?,
    address: json['address'] as String?,
    society: json['society'] as String?,
    flat: json['flat'] as String?,
    notes: json['notes'] as String?,
  );
}

class Session {
  const Session({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.needsProfile,
  });

  final String accessToken;
  final String refreshToken;
  final AppUser user;
  final bool needsProfile;

  Session copyWith({
    String? accessToken,
    String? refreshToken,
    AppUser? user,
    bool? needsProfile,
  }) => Session(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    user: user ?? this.user,
    needsProfile: needsProfile ?? this.needsProfile,
  );
}

/// In-memory session (tokens + current user). `null` means signed out.
// TODO: persist tokens (e.g. flutter_secure_storage) once the backend exists.
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  void start(Session session) => state = session;

  void updateUser(AppUser user, {bool? needsProfile}) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(user: user, needsProfile: needsProfile);
  }

  void updateTokens({required String accessToken, String? refreshToken}) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  void clear() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);
