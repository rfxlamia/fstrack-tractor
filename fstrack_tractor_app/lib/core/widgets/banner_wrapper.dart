import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/ui_strings.dart';
import '../network/connectivity_checker.dart';
import '../theme/app_spacing.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';
import '../../features/weather/presentation/bloc/weather_event.dart';
import 'animated_banner.dart';
import 'banner_priority_manager.dart';
import 'offline_banner.dart';

class BannerWrapper extends StatefulWidget {
  final Widget child;
  final ConnectivityChecker connectivityChecker;

  const BannerWrapper({
    super.key,
    required this.child,
    required this.connectivityChecker,
  });

  @override
  State<BannerWrapper> createState() => _BannerWrapperState();
}

class _BannerWrapperState extends State<BannerWrapper> {
  static const Duration _bannerDuration = Duration(milliseconds: 300);
  static const Curve _bannerCurve = Curves.easeOut;
  static const double _bannerHeight = AppSpacing.touchTargetMin;
  static const _priorityManager = BannerPriorityManager();

  bool _isOffline = false;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final isOnline = await widget.connectivityChecker.isOnline();
    if (!mounted) return;
    setState(() => _isOffline = !isOnline);
  }

  void _handleRefresh(BuildContext context) {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) <
            const Duration(milliseconds: 500)) {
      return;
    }
    _lastTapTime = now;

    context.read<WeatherBloc>().add(const RefreshWeather());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(UIStrings.offlineRetryMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityStatus>(
      stream: widget.connectivityChecker.onConnectivityChanged,
      builder: (context, snapshot) {
        // Update _isOffline state when stream emits
        if (snapshot.hasData) {
          final newOfflineState = snapshot.data == ConnectivityStatus.offline;
          if (newOfflineState != _isOffline) {
            // Schedule state update after build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _isOffline = newOfflineState);
              }
            });
          }
        }

        final isOffline = snapshot.hasData
            ? snapshot.data == ConnectivityStatus.offline
            : _isOffline;

        // TODO(Story 4.2): Replace with actual session warning check from AuthLocalDataSource
        const shouldShowSessionWarning = false;

        final activeBanner = _priorityManager.getActiveBanner(
          isOffline: isOffline,
          shouldShowSessionWarning: shouldShowSessionWarning,
        );

        return Stack(
          children: [
            AnimatedPadding(
              duration: _bannerDuration,
              curve: _bannerCurve,
              padding: EdgeInsets.only(
                top: activeBanner != null ? _bannerHeight : 0,
              ),
              child: widget.child,
            ),
            AnimatedBanner(
              isVisible: activeBanner == BannerType.offline,
              duration: _bannerDuration,
              curve: _bannerCurve,
              child: SafeArea(
                bottom: false,
                child: OfflineBanner(
                  isVisible: activeBanner == BannerType.offline,
                  onTap: () => _handleRefresh(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
