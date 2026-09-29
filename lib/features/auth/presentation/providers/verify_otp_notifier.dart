import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/session_store.dart';
import '../../data/auth_repository.dart';
import '../../data/models/auth_response.dart';
import 'sign_up_notifier.dart';

class VerifyOtpNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// On success saves the tokens in the session; the router then moves on
  /// to details (new user) or home (returning user).
  /// Failures are [OtpVerificationException]s in the error state.
  Future<void> verify(String otp) async {
    final pending = ref.read(pendingSignUpProvider);
    if (pending == null) {
      state = AsyncError(
        const OtpVerificationException(
          OtpFailure.other,
          'Session expired. Please sign up again.',
        ),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .verifyOtp(email: pending.email, otp: otp),
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
            user:
                auth.user ??
                AppUser(id: '', phone: pending.phone, email: pending.email),
            needsProfile: auth.needsProfile,
          ),
        );
  }

  /// Clears a retryable error once the user edits the code.
  void clearError() {
    if (state.hasError) state = const AsyncData(null);
  }
}

final verifyOtpProvider =
    AsyncNotifierProvider.autoDispose<VerifyOtpNotifier, void>(
      VerifyOtpNotifier.new,
    );

class ResendOtpNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Requests a new code. Failures are [ResendOtpException]s in the error
  /// state. On success the verify error is cleared, since the new code
  /// comes with fresh attempts.
  Future<void> resend() async {
    final pending = ref.read(pendingSignUpProvider);
    if (pending == null) return;

    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).resendOtp(email: pending.email),
    );
    if (!ref.mounted) return;
    state = result;
    if (!result.hasError) ref.read(verifyOtpProvider.notifier).clearError();
  }
}

final resendOtpProvider =
    AsyncNotifierProvider.autoDispose<ResendOtpNotifier, void>(
      ResendOtpNotifier.new,
    );
