import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

/// Data source for first-time user hints/tooltips persistence using Hive
///
/// Stores completed tooltip keys locally to support:
/// - Tooltip sequence tracking
/// - App kill recovery (resume from last incomplete tooltip)
/// - Completion tracking across sessions
///
/// **Box name:** `first_time_hints`
/// **Key:** `completed_tooltips` (List<String>)
///
/// **Note:** The Hive box must be opened in main.dart before using this class:
/// ```dart
/// await Hive.openBox(FirstTimeLocalDataSource.boxName);
/// ```
@lazySingleton
class FirstTimeLocalDataSource {
  static const String _boxName = 'first_time_hints';
  static const String _completedTooltipsKey = 'completed_tooltips';

  /// Get the box name for external reference (e.g., main.dart initialization)
  static String get boxName => _boxName;

  /// Get the already-opened Hive box
  Box get _box => Hive.box(_boxName);

  /// Get all completed tooltip keys
  ///
  /// Returns a set of tooltip keys that have been dismissed
  /// Empty set if no tooltips completed yet
  Set<String> getCompletedTooltips() {
    final List<dynamic>? stored = _box.get(_completedTooltipsKey);
    return Set<String>.from(stored ?? []);
  }

  /// Mark a tooltip as completed by its key
  ///
  /// Adds the key to the completed set and persists immediately
  /// Use this when user dismisses a tooltip
  ///
  /// [key] - The unique identifier for the tooltip (e.g., 'weather', 'menu_card')
  Future<void> markTooltipCompleted(String key) async {
    final completed = getCompletedTooltips();
    completed.add(key);
    await _box.put(_completedTooltipsKey, completed.toList());
  }

  /// Check if all tooltips in the sequence are completed
  ///
  /// Returns true if the completed set contains all expected tooltip keys
  bool areAllTooltipsCompleted() {
    final completed = getCompletedTooltips();
    return completed.contains('weather') && completed.contains('menu_card');
  }

  /// Get the next incomplete tooltip key
  ///
  /// Returns the first key from ['weather', 'menu_card'] that is not completed
  /// Returns null if all tooltips are completed
  String? getNextIncompleteTooltip() {
    final completed = getCompletedTooltips();
    if (!completed.contains('weather')) return 'weather';
    if (!completed.contains('menu_card')) return 'menu_card';
    return null;
  }

  /// Reset all completed tooltips (for testing or debugging)
  ///
  /// Clears the completed set entirely
  Future<void> reset() async {
    await _box.delete(_completedTooltipsKey);
  }

  /// Check if a specific tooltip is completed
  ///
  /// [key] - The tooltip key to check
  /// Returns true if the tooltip has been completed
  bool isTooltipCompleted(String key) {
    return getCompletedTooltips().contains(key);
  }
}
