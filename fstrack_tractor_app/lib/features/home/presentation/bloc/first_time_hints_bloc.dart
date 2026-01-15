import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/first_time_local_data_source.dart';

part 'first_time_hints_event.dart';
part 'first_time_hints_state.dart';

/// BLoC for managing first-time user hints/tooltip state
///
/// Handles:
/// - Loading persisted completion state
/// - Tracking current tooltip in sequence
/// - Persisting completion when user dismisses tooltips
/// - Server sync when all tooltips are completed (best-effort)
@lazySingleton
class FirstTimeHintsBloc
    extends Bloc<FirstTimeHintsEvent, FirstTimeHintsState> {
  final FirstTimeLocalDataSource _dataSource;
  final ApiClient _apiClient;

  FirstTimeHintsBloc({
    required FirstTimeLocalDataSource dataSource,
    required ApiClient apiClient,
  })  : _dataSource = dataSource,
        _apiClient = apiClient,
        super(const FirstTimeHintsState()) {
    on<LoadCompletedTooltips>(_onLoadCompletedTooltips);
    on<TooltipDismissed>(_onTooltipDismissed);
  }

  Future<void> _onLoadCompletedTooltips(
    LoadCompletedTooltips event,
    Emitter<FirstTimeHintsState> emit,
  ) async {
    final completed = _dataSource.getCompletedTooltips();
    final currentTooltip = _getNextTooltip(completed);
    emit(FirstTimeHintsState(
      completedTooltips: completed,
      currentTooltip: currentTooltip,
    ));
  }

  Future<void> _onTooltipDismissed(
    TooltipDismissed event,
    Emitter<FirstTimeHintsState> emit,
  ) async {
    final completed = Set<String>.from(state.completedTooltips)
      ..add(event.tooltipKey);
    await _dataSource.markTooltipCompleted(event.tooltipKey);

    final currentTooltip = _getNextTooltip(completed);
    emit(FirstTimeHintsState(
      completedTooltips: completed,
      currentTooltip: currentTooltip,
    ));

    // Check if all tooltips are now completed and trigger sync
    if (currentTooltip == null) {
      await _syncFirstTimeStatus();
    }
  }

  /// Sync first-time status to server (best-effort)
  ///
  /// If online: calls PATCH /api/v1/users/me/first-time
  /// If offline: skips silently (local state is source of truth)
  Future<void> _syncFirstTimeStatus() async {
    try {
      await _apiClient.dio.patch(
        '/api/v1/users/me/first-time',
        data: {'isFirstTime': false},
      );
    } catch (e) {
      // Best-effort sync: silently ignore errors when offline
      // Local state is source of truth for tooltip display
    }
  }

  String? _getNextTooltip(Set<String> completed) {
    if (!completed.contains('weather')) return 'weather';
    if (!completed.contains('menu_card')) return 'menu_card';
    return null;
  }
}
