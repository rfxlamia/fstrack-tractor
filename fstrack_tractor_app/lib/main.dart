import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.initialize();
  await configureDependencies();

  // Check auth status on app start (AC9: Initial Route Determination)
  getIt<AuthBloc>().add(const CheckAuthStatus());

  runApp(const FsTrackApp());
}

class FsTrackApp extends StatelessWidget {
  const FsTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide AuthBloc at app level (AC11: Router Provider Integration)
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: 'FSTrack Tractor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: getIt<AppRouter>().router,
      ),
    );
  }
}
