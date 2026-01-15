import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/ui_strings.dart';
import '../../../../core/network/connectivity_checker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/banner_wrapper.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/services/session_expiry_checker.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../../weather/presentation/widgets/weather_widget.dart';
import '../widgets/clock_widget.dart';
import '../widgets/coming_soon_bottom_sheet.dart';
import '../widgets/greeting_header.dart';
import '../widgets/role_based_menu_cards.dart';

/// Home Page - Main landing page after successful authentication
///
/// Displays personalized dashboard with greeting, clock, weather widget, and menu cards.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: BlocProvider<WeatherBloc>(
        create: (context) => getIt<WeatherBloc>(),
        child: BannerWrapper(
          connectivityChecker: getIt<ConnectivityChecker>(),
          sessionExpiryChecker: getIt<SessionExpiryChecker>(),
          child: const SafeArea(
            child: HomePageContent(),
          ),
        ),
      ),
      // AC6: FAB with role-based visibility
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Build FAB for Kasie role only
  Widget? _buildFab(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthSuccess) return const SizedBox.shrink();
        if (state.user.role != UserRole.kasie) return const SizedBox.shrink();

        return FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => ComingSoonBottomSheet.show(
            context,
            UIStrings.menuCardCreateTitle,
          ),
          child: const Icon(Icons.add),
        );
      },
    );
  }
}

/// Home page content widget (separated for BlocProvider access)
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.lg),
          // GreetingHeader - from AuthBloc
          GreetingHeader(),
          SizedBox(height: AppSpacing.xs),
          // Clock Widget - standalone
          ClockWidget(),
          SizedBox(height: AppSpacing.lg),
          // WeatherWidget - Story 3.3
          WeatherWidget(),
          SizedBox(height: AppSpacing.md),
          // AC7: RoleBasedMenuCards - Story 3.4
          RoleBasedMenuCards(),
        ],
      ),
    );
  }
}
