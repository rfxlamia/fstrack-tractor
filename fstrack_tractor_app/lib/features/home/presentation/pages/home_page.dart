import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/ui_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/clock_widget.dart';
import '../widgets/greeting_header.dart';

/// Home Page - Main landing page after successful authentication
///
/// Displays personalized dashboard with greeting, clock, and placeholders
/// for weather widget (Story 3.3) and menu cards (Story 3.4).
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
      body: SafeArea(
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
              // WeatherWidget placeholder - Story 3.3
              _buildPlaceholder(
                icon: Icons.cloud,
                title: UIStrings.weatherPlaceholderTitle,
                subtitle: UIStrings.weatherPlaceholderSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              // MenuCards placeholder - Story 3.4
              _buildPlaceholder(
                icon: Icons.menu_book,
                title: UIStrings.menuCardsPlaceholderTitle,
                subtitle: UIStrings.menuCardsPlaceholderSubtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.greyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.w600s12.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.w400s10.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
