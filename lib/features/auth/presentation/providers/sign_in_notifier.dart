import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';

class PendingLogin {
  const PendingLogin({required this.phone, required this.email});

  final String phone;
  final String email;
}

/// Phone + email the OTP was sent to; used by Verify OTP and resend.
class PendingLoginNotifier extends Notifier<PendingLogin?> {
  @override
  PendingLogin? build() => null;

  void set(PendingLogin value) => state = value;
}

final pendingLoginProvider =
    NotifierProvider<PendingLoginNotifier, PendingLogin?>(
      PendingLoginNotifier.new,
    );

class SignInNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns true when the OTP was sent.
  Future<bool> sendOtp({required String phone, required String email}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () =>
          ref.read(authRepositoryProvider).sendOtp(phone: phone, email: email),
    );
    if (!ref.mounted) return false;
    state = result;
    if (result.hasError) return false;
    ref
        .read(pendingLoginProvider.notifier)
        .set(PendingLogin(phone: phone, email: email));
    return true;
  }
}

final signInProvider = AsyncNotifierProvider.autoDispose<SignInNotifier, void>(
  SignInNotifier.new,
);
