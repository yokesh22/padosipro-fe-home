import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/storage/session_store.dart';
import '../../data/auth_repository.dart';
import 'sign_in_notifier.dart';

class VerifyOtpNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// On success starts the session; the router then moves on to
  /// details (new user) or home (returning user).
  Future<void> verify(String otp) async {
    final pending = ref.read(pendingLoginProvider);
    if (pending == null) {
      state = AsyncError(
        const AppException('Session expired. Please sign in again.'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .verifyOtp(phone: pending.phone, email: pending.email, otp: otp),
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
            user: auth.user,
            needsProfile: auth.isNewUser,
          ),
        );
  }

  /// Re-sends the OTP. Doesn't enter the loading state so the Verify
  /// button isn't affected; failures surface as an error state.
  Future<void> resend() async {
    final pending = ref.read(pendingLoginProvider);
    if (pending == null) return;
    final result = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .sendOtp(phone: pending.phone, email: pending.email),
    );
    if (ref.mounted && result.hasError) state = result;
  }
}

final verifyOtpProvider =
    AsyncNotifierProvider.autoDispose<VerifyOtpNotifier, void>(
      VerifyOtpNotifier.new,
    );
