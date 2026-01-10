import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: Routes.login,
  routes: [
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Login Page - Placeholder')),
      ),
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
