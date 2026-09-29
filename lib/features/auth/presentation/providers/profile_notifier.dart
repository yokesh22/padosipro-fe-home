import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/session_store.dart';
import '../../data/auth_repository.dart';

class ProfileNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Saves the profile; the router then moves to Home.
  Future<void> submit({
    required String name,
    String? address,
    String? society,
    String? flat,
    String? notes,
  }) async {
    String? blankToNull(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();

    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .completeProfile(
            name: name.trim(),
            address: blankToNull(address),
            society: blankToNull(society),
            flat: blankToNull(flat),
            notes: blankToNull(notes),
          ),
    );
    if (!ref.mounted) return;
    state = result.whenData((_) {});
    final user = result.value;
    if (user == null) return;

    ref.read(sessionProvider.notifier).updateUser(user, needsProfile: false);
  }
}

final profileProvider =
    AsyncNotifierProvider.autoDispose<ProfileNotifier, void>(
      ProfileNotifier.new,
    );
