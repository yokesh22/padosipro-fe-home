import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';

class PendingSignUp {
  const PendingSignUp({required this.phone, required this.email});

  final String phone;
  final String email;
}

/// Phone + email the OTP was sent to; used by Verify OTP and resend.
class PendingSignUpNotifier extends Notifier<PendingSignUp?> {
  @override
  PendingSignUp? build() => null;

  void set(PendingSignUp value) => state = value;
}

final pendingSignUpProvider =
    NotifierProvider<PendingSignUpNotifier, PendingSignUp?>(
      PendingSignUpNotifier.new,
    );

class SignUpNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Returns true when the OTP was sent.
  Future<bool> sendOtp({
    required String phone,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .sendOtp(phone: phone, email: email, password: password),
    );
    if (!ref.mounted) return false;
    state = result;
    if (result.hasError) return false;
    ref
        .read(pendingSignUpProvider.notifier)
        .set(PendingSignUp(phone: phone, email: email));
    return true;
  }
}

final signUpProvider = AsyncNotifierProvider.autoDispose<SignUpNotifier, void>(
  SignUpNotifier.new,
);
