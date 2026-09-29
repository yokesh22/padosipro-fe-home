import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value storage (Android Keystore / iOS Keychain) for
/// secrets such as auth tokens. Not wired into the session yet.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    // Readable after the first unlock since boot, so a token refresh can
    // run while the app is in the background.
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  ),
);
