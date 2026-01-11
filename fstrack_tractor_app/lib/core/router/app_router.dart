import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/pages/login_page.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: Routes.login,
  routes: [
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Home Page - Placeholder')),
      ),
    ),
  ],
);
