import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/ui_strings.dart';
import '../network/connectivity_checker.dart';
import '../theme/app_spacing.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';
import '../../features/weather/presentation/bloc/weather_event.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/domain/services/session_expiry_checker.dart';
import '../../features/auth/presentation/widgets/session_warning_banner.dart';
import 'animated_banner.dart';
import 'banner_priority_manager.dart';
import 'offline_banner.dart';

class BannerWrapper extends StatefulWidget {
  final Widget child;
  final ConnectivityChecker connectivityChecker;
  final SessionExpiryChecker sessionExpiryChecker;

  const BannerWrapper({
    super.key,
    required this.child,
    required this.connectivityChecker,
    required this.sessionExpiryChecker,
  });

  @override
  State<BannerWrapper> createState() => _BannerWrapperState();
}

class _BannerWrapperState extends State<BannerWrapper>
    with WidgetsBindingObserver {
  static const Duration _bannerDuration = Duration(milliseconds: 300);
  static const Curve _bannerCurve = Curves.easeOut;
  static const _priorityManager = BannerPriorityManager();

  bool _isOffline = false;
  bool _shouldShowSessionWarning = false;
  int _daysUntilExpiry = -1;
  DateTime? _lastTapTime;
  Timer? _expiryCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialConnectivity();
    _checkSessionWarning();

    _expiryCheckTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _checkSessionWarning();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _expiryCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSessionWarning();
    }
  }

  Future<void> _checkSessionWarning() async {
    // Trigger AuthBloc check for force logout
    context.read<AuthBloc>().add(const SessionExpiryChecked());

    final shouldShow = await widget.sessionExpiryChecker.shouldShowWarning();
    final canShow = await widget.sessionExpiryChecker.canShowWarningToday();
    final days = await widget.sessionExpiryChecker.getDaysUntilExpiry();

    if (!mounted) return;
    setState(() {
      _shouldShowSessionWarning = shouldShow && canShow;
      _daysUntilExpiry = days;
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final isOnline = await widget.connectivityChecker.isOnline();
    if (!mounted) return;
    setState(() => _isOffline = !isOnline);
  }

  void _handleRefresh(BuildContext context) {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastTapTime = now;

    context.read<WeatherBloc>().add(const RefreshWeather());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(UIStrings.offlineRetryMessage)),
    );
  }

  double _getBannerHeight(BannerType? type) {
    if (type == BannerType.sessionWarning) return 56.0;
    if (type == BannerType.offline) return AppSpacing.touchTargetMin;
    return 0;
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

        final activeBanner = _priorityManager.getActiveBanner(
          isOffline: isOffline,
          shouldShowSessionWarning: _shouldShowSessionWarning,
        );

        final bannerHeight = _getBannerHeight(activeBanner);

        return Stack(
          children: [
            AnimatedPadding(
              duration: _bannerDuration,
              curve: _bannerCurve,
              padding: EdgeInsets.only(
                top: activeBanner != null ? bannerHeight : 0,
              ),
              child: widget.child,
            ),
            AnimatedBanner(
              isVisible: activeBanner == BannerType.sessionWarning,
              duration: _bannerDuration,
              curve: _bannerCurve,
              child: SafeArea(
                bottom: false,
                child: SessionWarningBanner(
                  daysRemaining: _daysUntilExpiry,
                  onDismiss: () {
                    widget.sessionExpiryChecker.markWarningShown();
                    setState(() => _shouldShowSessionWarning = false);
                  },
                ),
              ),
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
