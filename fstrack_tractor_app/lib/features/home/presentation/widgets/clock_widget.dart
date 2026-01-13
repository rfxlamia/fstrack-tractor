import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ClockWidget - Displays current time in WIB timezone
///
/// Features:
/// - Shows time in "HH:mm WIB" format (24-hour)
/// - Auto-updates every minute using Timer
/// - Uses WIB timezone (UTC+7) hardcoded
/// - Optional testTime parameter for deterministic testing
///
/// **TIMEZONE: WIB (UTC+7) HARDCODED**
/// - Business Requirement: All users see Jakarta time regardless of device settings
/// - See: [AppConstants.wibOffset] for detailed timezone documentation
class ClockWidget extends StatefulWidget {
  /// Optional initial time for testing. If null, uses DateTime.now().
  final DateTime? testTime;

  const ClockWidget({super.key, this.testTime});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  Timer? _timer;
  late DateTime _wibTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Only start timer if not in test mode
    if (widget.testTime == null) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null; // Explicitly nullify to prevent memory leak
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      if (widget.testTime != null) {
        // Test mode: use provided time converted to WIB
        _wibTime = widget.testTime!.toUtc().add(AppConstants.wibOffset);
      } else {
        // Production: use current time
        _wibTime = DateTime.now().toUtc().add(AppConstants.wibOffset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeString = _formatTime(_wibTime);

    return Text(
      '$timeString WIB',
      style: AppTextStyles.w500s12.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
