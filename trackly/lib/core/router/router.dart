import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/features/navigation_bar/navigation_bar.dart';
import 'package:trackly/features/screens/home_screen/ui/home_screen.dart';
import 'package:trackly/features/screens/onboarding/ui/onboarding.dart';
import 'package:trackly/features/screens/statistic_screen/ui/statisctic_screen.dart';
import 'package:trackly/features/screens/user_screen/ui/user_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
// ignore: unused_element
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/onboarding',
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Navbar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistics',
              builder: (context, state) => const statiscticScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/user',
              builder: (context, state) => const userScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
