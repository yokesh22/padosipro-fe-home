import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/session_store.dart';
import '../../data/auth_repository.dart';

class SignInNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// On success starts the session; the router then moves on to Home, or
  /// to "A few details" if the account has no name yet. Never shows OTP.
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .login(email: email, password: password),
    );
    if (!ref.mounted) return;
    state = result.whenData((_) {});
    final auth = result.value;
    if (auth == null) return;

    ref
        .read(sessionProvider.notifier)
        .start(
          Session(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
            user: auth.user ?? AppUser(id: '', phone: '', email: email),
            needsProfile: auth.needsProfile,
          ),
        );
  }
}

final signInProvider = AsyncNotifierProvider.autoDispose<SignInNotifier, void>(
  SignInNotifier.new,
);
