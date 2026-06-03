import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/library/library_screen.dart';
import '../../presentation/learn/learn_screen.dart';
import '../../presentation/lesson/lesson_screen.dart';
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/paywall/paywall_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/providers/app_providers.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/shell/app_shell.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// App router. A [StatefulShellRoute] backs the bottom navigation (each tab
/// keeps its own navigation stack); lessons/paywall/settings push above it.
final routerProvider = Provider<GoRouter>((ref) {
  // Reactively redirect when onboarding completes, without rebuilding the router.
  final refresh = ValueNotifier<bool>(ref.read(onboardingDoneProvider));
  ref.listen(onboardingDoneProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.learn,
    refreshListenable: refresh,
    redirect: (context, state) {
      final done = ref.read(onboardingDoneProvider);
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!done && !atOnboarding) return Routes.onboarding;
      if (done && atOnboarding) return Routes.learn;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.learn,
                builder: (context, state) => const LearnScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.lesson,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => LessonScreen(
          lessonId: state.pathParameters['lessonId']!,
        ),
      ),
      GoRoute(
        path: Routes.paywall,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
