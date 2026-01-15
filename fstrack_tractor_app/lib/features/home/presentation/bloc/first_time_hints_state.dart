part of 'first_time_hints_bloc.dart';

/// State for FirstTimeHintsBloc
class FirstTimeHintsState {
  /// Set of tooltip keys that have been completed
  final Set<String> completedTooltips;

  /// Current tooltip to show (null if all completed)
  final String? currentTooltip;

  const FirstTimeHintsState({
    this.completedTooltips = const {},
    this.currentTooltip,
  });

  /// Check if all tooltips are completed
  bool get isAllCompleted => currentTooltip == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FirstTimeHintsState &&
        other.completedTooltips.length == completedTooltips.length &&
        other.completedTooltips.containsAll(completedTooltips) &&
        other.currentTooltip == currentTooltip;
  }

  @override
  int get hashCode => completedTooltips.hashCode ^ currentTooltip.hashCode;
}
