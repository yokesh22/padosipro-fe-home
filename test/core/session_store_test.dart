import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padosipro/core/storage/session_store.dart';

const _session = Session(
  accessToken: 'access',
  refreshToken: 'refresh',
  user: AppUser(
    id: 'u1',
    phone: '+919876543210',
    email: 'a@b.com',
    fullName: 'Yokesh Kumar',
  ),
  needsProfile: false,
);

/// Lets the queued secure-storage writes finish.
Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<Session?> _restoreInNewContainer() async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await container.read(sessionProvider.notifier).restore();
  return container.read(sessionProvider);
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('a started session is restored on the next launch', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(sessionProvider.notifier).start(_session);
    await _settle();

    final restored = await _restoreInNewContainer();
    expect(restored?.accessToken, 'access');
    expect(restored?.refreshToken, 'refresh');
    expect(restored?.user.firstName, 'Yokesh');
    expect(restored?.needsProfile, isFalse);
  });

  test('refreshed tokens are saved', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(sessionProvider.notifier);
    notifier.start(_session);
    notifier.updateTokens(accessToken: 'access2', refreshToken: 'refresh2');
    await _settle();

    final restored = await _restoreInNewContainer();
    expect(restored?.accessToken, 'access2');
    expect(restored?.refreshToken, 'refresh2');
  });

  test('clear removes the saved session', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(sessionProvider.notifier);
    notifier.start(_session);
    notifier.clear();
    await _settle();

    expect(await _restoreInNewContainer(), isNull);
  });

  test('an unreadable saved session starts signed out', () async {
    FlutterSecureStorage.setMockInitialValues({'session': 'not json'});
    expect(await _restoreInNewContainer(), isNull);
  });
}
