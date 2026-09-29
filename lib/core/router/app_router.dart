import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/profile_details_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/verify_otp_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/tasks/presentation/screens/all_services_screen.dart';
import '../storage/session_store.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Re-runs `redirect` whenever the session changes (login, profile, logout).
  final refresh = ValueNotifier<Session?>(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: Routes.signIn,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;

      if (session == null) {
        return Routes.public.contains(location) ? null : Routes.signIn;
      }
      if (session.needsProfile) {
        return location == Routes.details ? null : Routes.details;
      }
      if (Routes.public.contains(location) || location == Routes.details) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.verifyOtp,
        builder: (context, state) => const VerifyOtpScreen(),
      ),
      GoRoute(
        path: Routes.details,
        builder: (context, state) => const ProfileDetailsScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.services,
        builder: (context, state) =>
            AllServicesScreen(initialCategory: state.extra as int?),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
