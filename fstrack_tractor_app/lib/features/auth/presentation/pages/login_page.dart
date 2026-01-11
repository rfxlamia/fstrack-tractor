import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import 'login_form.dart';

/// Login page - entry point for user authentication
/// Uses Clean Architecture pattern with data/domain/presentation layers
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (_) => getIt<AuthBloc>(),
          child: const LoginForm(),
        ),
      ),
    );
  }
}
