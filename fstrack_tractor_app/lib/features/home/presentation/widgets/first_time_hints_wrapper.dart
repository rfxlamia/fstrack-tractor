import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/tooltip_overlay.dart';
import '../bloc/first_time_hints_bloc.dart';

/// FirstTimeHintsWrapper - Manages tooltip sequence for first-time users
///
/// Wraps HomePage content and displays contextual tooltips in sequence.
/// Handles:
/// - First-time detection from AuthState
/// - Tooltip sequence management
/// - Completion tracking
/// - App kill recovery (resumes from last incomplete tooltip)
///
/// **Usage:**
/// ```dart
/// FirstTimeHintsWrapper(
///   child: HomePageContent(),
///   weatherWidgetKey: _weatherKey,
///   menuCardKey: _menuCardKey,
/// )
/// ```
class FirstTimeHintsWrapper extends StatefulWidget {
  /// The child widget to wrap (typically HomePageContent)
  final Widget child;

  /// GlobalKey for the WeatherWidget (for tooltip positioning)
  final GlobalKey weatherWidgetKey;

  /// GlobalKey for the "Lihat Rencana Kerja" MenuCard (for tooltip positioning)
  final GlobalKey menuCardKey;

  const FirstTimeHintsWrapper({
    super.key,
    required this.child,
    required this.weatherWidgetKey,
    required this.menuCardKey,
  });

  @override
  State<FirstTimeHintsWrapper> createState() => _FirstTimeHintsWrapperState();
}

class _FirstTimeHintsWrapperState extends State<FirstTimeHintsWrapper> {
  late FirstTimeHintsBloc _hintsBloc;

  @override
  void initState() {
    super.initState();
    _hintsBloc = getIt<FirstTimeHintsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _hintsBloc,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return widget.child;
          }

          final user = authState.user;

          // Check if user is first-time and hasn't completed all tooltips
          if (!user.isFirstTime) {
            return widget.child;
          }

          // Check if all tooltips are already completed
          if (_hintsBloc.state.isAllCompleted) {
            return widget.child;
          }

          // Show tooltip overlay
          return FirstTimeTooltipOverlay(
            hintsBloc: _hintsBloc,
            weatherWidgetKey: widget.weatherWidgetKey,
            menuCardKey: widget.menuCardKey,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Internal widget that displays the tooltip overlay
class FirstTimeTooltipOverlay extends StatefulWidget {
  final FirstTimeHintsBloc hintsBloc;
  final GlobalKey weatherWidgetKey;
  final GlobalKey menuCardKey;
  final Widget child;

  const FirstTimeTooltipOverlay({
    super.key,
    required this.hintsBloc,
    required this.weatherWidgetKey,
    required this.menuCardKey,
    required this.child,
  });

  @override
  State<FirstTimeTooltipOverlay> createState() =>
      _FirstTimeTooltipOverlayState();
}

class _FirstTimeTooltipOverlayState extends State<FirstTimeTooltipOverlay> {
  @override
  void initState() {
    super.initState();
    // Load persisted completion state
    widget.hintsBloc.add(const LoadCompletedTooltips());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirstTimeHintsBloc, FirstTimeHintsState>(
      builder: (context, state) {
        // Get the current tooltip to show
        final currentTooltip = state.currentTooltip;

        if (currentTooltip == null) {
          // All tooltips completed, show child without overlay
          return widget.child;
        }

        // Build overlay based on current tooltip
        return _buildTooltipOverlay(state, currentTooltip);
      },
    );
  }

  Widget _buildTooltipOverlay(
      FirstTimeHintsState state, String currentTooltip) {
    late final TooltipPosition position;
    late final String message;

    switch (currentTooltip) {
      case 'weather':
        position = TooltipPosition.bottom;
        message = 'Lihat prakiraan cuaca untuk merencanakan aktivitas lapangan';
        break;
      case 'menu_card':
        position = TooltipPosition.top;
        message = 'Tap untuk melihat rencana kerja Anda';
        break;
      default:
        return widget.child;
    }

    return TooltipOverlay(
      position: position,
      message: message,
      onDismiss: () => widget.hintsBloc.add(TooltipDismissed(currentTooltip)),
      child: widget.child,
    );
  }
}
