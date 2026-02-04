import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/connectivity_checker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/banner_wrapper.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/services/session_expiry_checker.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../../weather/presentation/widgets/weather_widget.dart';
import '../../../work_plan/presentation/bloc/work_plan_bloc.dart';
import '../widgets/clock_widget.dart';
import '../../../work_plan/presentation/widgets/create_bottom_sheet.dart';
import '../widgets/first_time_hints_wrapper.dart';
import '../widgets/greeting_header.dart';
import '../widgets/role_based_menu_cards.dart';

/// Home Page - Main landing page after successful authentication
///
/// Displays personalized dashboard with greeting, clock, weather widget, and menu cards.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WeatherBloc>(
          create: (context) => getIt<WeatherBloc>(),
        ),
        BlocProvider<WorkPlanBloc>(
          create: (context) => getIt<WorkPlanBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('FSTrack Tractor'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            actions: [
              // Temporary logout button - will be moved to settings in post-MVP
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () =>
                    context.read<AuthBloc>().add(const LogoutRequested()),
              ),
            ],
          ),
          body: BannerWrapper(
            connectivityChecker: getIt<ConnectivityChecker>(),
            sessionExpiryChecker: getIt<SessionExpiryChecker>(),
            child: const SafeArea(
              child: HomePageContent(),
            ),
          ),
          // AC6: FAB with role-based visibility
          floatingActionButton: _buildFab(context),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }

  /// Build FAB for Kasie PG role only (CREATE permission)
  Widget? _buildFab(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthSuccess) return const SizedBox.shrink();
        if (!state.user.role.canCreateWorkPlan) return const SizedBox.shrink();

        return FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => CreateBottomSheet.show(context),
          child: const Icon(Icons.add),
        );
      },
    );
  }
}

/// Home page content widget (separated for BlocProvider access)
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final GlobalKey _weatherWidgetKey = GlobalKey();
  final GlobalKey _viewMenuCardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return FirstTimeHintsWrapper(
      weatherWidgetKey: _weatherWidgetKey,
      menuCardKey: _viewMenuCardKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // GreetingHeader - from AuthBloc
            const GreetingHeader(),
            const SizedBox(height: AppSpacing.xs),
            // Clock Widget - standalone
            const ClockWidget(),
            const SizedBox(height: AppSpacing.lg),
            // WeatherWidget - Story 3.3
            WeatherWidget(key: _weatherWidgetKey),
            const SizedBox(height: AppSpacing.md),
            // AC7: RoleBasedMenuCards - Story 3.4
            RoleBasedMenuCards(viewMenuCardKey: _viewMenuCardKey),
          ],
        ),
      ),
    );
  }
}
