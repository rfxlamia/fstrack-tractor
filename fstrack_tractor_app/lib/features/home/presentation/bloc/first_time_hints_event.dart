part of 'first_time_hints_bloc.dart';

/// Events for FirstTimeHintsBloc
abstract class FirstTimeHintsEvent {
  const FirstTimeHintsEvent();
}

/// Load persisted completion state from local storage
class LoadCompletedTooltips extends FirstTimeHintsEvent {
  const LoadCompletedTooltips();
}

/// User dismissed a tooltip
class TooltipDismissed extends FirstTimeHintsEvent {
  final String tooltipKey;

  const TooltipDismissed(this.tooltipKey);
}
