import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/storage/session_store.dart';
import '../../data/auth_repository.dart';

class ProfileNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Saves the name, then the address if one was entered. On success the
  /// router moves to Home. Failures are [AppException]s in the error state;
  /// 401/404 also end the session so the router returns to sign-in.
  Future<void> submit({
    required String fullName,
    String? flatUnit,
    String? addressLine,
    String? society,
    String? notes,
  }) async {
    String? blankToNull(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();

    final flat = blankToNull(flatUnit);
    final line = blankToNull(addressLine);
    final soc = blankToNull(society);
    final note = blankToNull(notes);
    final hasAddress = [flat, line, soc, note].any((v) => v != null);

    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.updateProfile(fullName: fullName.trim());
      if (!hasAddress) return user;
      final address = await repo.addAddress(
        flatUnit: flat ?? '',
        addressLine: line,
        society: soc,
        notes: note,
      );
      return user.copyWith(defaultAddress: address);
    });
    if (!ref.mounted) return;
    state = result.whenData((_) {});

    final session = ref.read(sessionProvider.notifier);
    final user = result.value;
    if (user != null) {
      session.updateUser(user, needsProfile: false);
      return;
    }
    final status = (result.error as AppException?)?.statusCode;
    // Token rejected, or the user no longer exists: restart onboarding.
    if (status == 401 || status == 404) session.clear();
  }

  /// Clears a server error once the user edits the form.
  void clearError() {
    if (state.hasError) state = const AsyncData(null);
  }
}

final profileProvider =
    AsyncNotifierProvider.autoDispose<ProfileNotifier, void>(
      ProfileNotifier.new,
    );
