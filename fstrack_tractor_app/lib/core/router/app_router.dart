import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import 'go_router_refresh_stream.dart';
import 'routes.dart';

/// AppRouter - centralized routing configuration with auth integration
///
/// Uses dependency injection to access AuthBloc and configure routes
/// with auth-aware redirect logic and first-time user flow.
@lazySingleton
class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter router;

  AppRouter({required this.authBloc}) {
    router = GoRouter(
      initialLocation: Routes.login,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: _redirect,
      routes: [
        GoRoute(
          path: Routes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: Routes.home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: Routes.onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
      ],
    );
  }

  /// Redirect logic with first-time user check
  ///
  /// Implements AC1-AC6 from Story 2.6:
  /// - Unauthenticated users → Login Page
  /// - Authenticated users → Home Page (or Onboarding if first-time)
  /// - First-time users on login → Onboarding Page
  /// - Logout → Login Page
  ///
  /// Note: First-time users CAN navigate from onboarding to home.
  /// Epic 5 will implement full onboarding flow with isFirstTime update.
  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    final isLoggedIn = authState is AuthSuccess;
    final isOnLoginPage = state.matchedLocation == Routes.login;

    // Not logged in and not on login page -> redirect to login
    if (!isLoggedIn && !isOnLoginPage) {
      return Routes.login;
    }

    // Logged in and on login page -> check first-time status
    if (isLoggedIn && isOnLoginPage) {
      final user = authState.user;
      // First-time user -> onboarding (Epic 5 will expand)
      if (user.isFirstTime) {
        return Routes.onboarding;
      }
      return Routes.home;
    }

    // No redirect needed - allow navigation between authenticated routes
    // First-time users can proceed from onboarding to home
    // Epic 5 will implement proper onboarding completion flow
    return null;
  }
}
