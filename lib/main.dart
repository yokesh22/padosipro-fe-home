import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/session_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore the saved login before the first frame, so a signed-in user
  // opens straight to Home instead of flashing the sign-up screen.
  final container = ProviderContainer();
  await container.read(sessionProvider.notifier).restore();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PadosiProApp(),
    ),
  );
}
