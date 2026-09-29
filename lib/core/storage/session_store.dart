import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage.dart';

class UserAddress {
  const UserAddress({
    required this.id,
    required this.flatUnit,
    this.addressLine,
    this.society,
    this.notes,
    this.isDefault = false,
  });

  final String id;
  final String flatUnit;
  final String? addressLine;
  final String? society;

  /// Gate or entry notes.
  final String? notes;
  final bool isDefault;

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
    id: json['id']?.toString() ?? '',
    flatUnit: json['flatUnit'] as String? ?? '',
    addressLine: json['addressLine'] as String?,
    society: json['society'] as String?,
    notes: json['notes'] as String?,
    isDefault: json['isDefault'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'flatUnit': flatUnit,
    'addressLine': addressLine,
    'society': society,
    'notes': notes,
    'isDefault': isDefault,
  };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.phone,
    required this.email,
    this.fullName,
    this.defaultAddress,
  });

  final String id;
  final String phone;
  final String email;
  final String? fullName;
  final UserAddress? defaultAddress;

  String get firstName {
    final trimmed = fullName?.trim() ?? '';
    return trimmed.isEmpty ? '' : trimmed.split(RegExp(r'\s+')).first;
  }

  AppUser copyWith({UserAddress? defaultAddress}) => AppUser(
    id: id,
    phone: phone,
    email: email,
    fullName: fullName,
    defaultAddress: defaultAddress ?? this.defaultAddress,
  );

  /// Parses the API's user object (`/api/users/me`, `user` of login and
  /// verify-email). `defaultAddress` only comes from [toJson].
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id']?.toString() ?? '',
    phone: json['phoneNumber'] as String? ?? '',
    email: json['email'] as String? ?? '',
    fullName: json['fullName'] as String?,
    defaultAddress: json['defaultAddress'] is Map<String, dynamic>
        ? UserAddress.fromJson(json['defaultAddress'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'phoneNumber': phone,
    'email': email,
    'fullName': fullName,
    if (defaultAddress != null) 'defaultAddress': defaultAddress!.toJson(),
  };
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

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    needsProfile: json['needsProfile'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': user.toJson(),
    'needsProfile': needsProfile,
  };
}

/// Saves the session (tokens + user) in secure storage so a login
/// survives app restarts.
class SessionStorage {
  const SessionStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'session';

  /// The saved session, or `null` if there is none or it can't be read
  /// (e.g. the Keystore was reset). An unreadable entry is deleted.
  Future<Session?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Could not restore the session: $e');
      await clear();
      return null;
    }
  }

  Future<void> write(Session session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (e) {
      debugPrint('Could not clear the saved session: $e');
    }
  }
}

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SessionStorage(ref.watch(secureStorageProvider)),
);

/// Current session (tokens + user). `null` means signed out. Every change
/// is saved to [SessionStorage]; [restore] loads it at launch.
class SessionNotifier extends Notifier<Session?> {
  /// Writes run one after another so a later change can't be overwritten
  /// by an earlier, slower one.
  Future<void> _saving = Future.value();

  @override
  Session? build() => null;

  /// Loads the saved session. Called once in `main()` before the first
  /// frame, so the router starts on the right screen.
  Future<void> restore() async {
    state = await ref.read(sessionStorageProvider).read();
  }

  void start(Session session) => _set(session);

  void updateUser(AppUser user, {bool? needsProfile}) {
    final current = state;
    if (current == null) return;
    _set(current.copyWith(user: user, needsProfile: needsProfile));
  }

  void updateTokens({required String accessToken, String? refreshToken}) {
    final current = state;
    if (current == null) return;
    _set(
      current.copyWith(accessToken: accessToken, refreshToken: refreshToken),
    );
  }

  void clear() => _set(null);

  void _set(Session? session) {
    state = session;
    final storage = ref.read(sessionStorageProvider);
    // A failed write only costs the login on the next launch; the
    // in-memory session keeps working.
    _saving = _saving
        .then((_) => session == null ? storage.clear() : storage.write(session))
        .catchError((Object e) => debugPrint('Could not save the session: $e'));
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);
