import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// GreetingHeader Widget - Time-based greeting with user's name
///
/// Displays personalized greeting based on WIB (UTC+7) time:
/// - 00:00-11:59: "Selamat Pagi"
/// - 12:00-14:59: "Selamat Siang"
/// - 15:00-17:59: "Selamat Sore"
/// - 18:00-23:59: "Selamat Malam"
///
/// **TIMEZONE: WIB (UTC+7) HARDCODED**
/// - Business Requirement: All users operate in Jakarta timezone regardless
///   of device settings (per Product Owner decision)
/// - See: [AppConstants.wibOffset] for detailed timezone documentation
///
/// User name is fetched from AuthBloc state with fallback to "User".
class GreetingHeader extends StatelessWidget {
  /// Optional time for testing different greetings. If null, uses DateTime.now().
  final DateTime? testTime;

  const GreetingHeader({super.key, this.testTime});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state is AuthSuccess ? state.user.fullName : 'User';
        final greeting = _getGreeting();

        return Text(
          '$greeting, $userName',
          style: AppTextStyles.w500s16.copyWith(
            color: AppColors.textPrimary,
          ),
        );
      },
    );
  }

  /// Returns greeting based on WIB time (UTC+7)
  /// Uses testTime if provided, otherwise DateTime.now()
  String _getGreeting() {
    final now = testTime ?? DateTime.now();
    final wibTime = now.toUtc().add(AppConstants.wibOffset);
    final hour = wibTime.hour;

    if (hour >= 0 && hour < 12) {
      return 'Selamat Pagi';
    } else if (hour >= 12 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}
