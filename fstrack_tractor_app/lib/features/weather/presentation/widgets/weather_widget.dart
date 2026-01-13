import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/ui_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../../domain/entities/weather_entity.dart';
import 'weather_icon_mapper.dart';
import 'weather_widget_skeleton.dart';

/// Weather widget displaying current weather conditions
///
/// Shows temperature, condition, icon, location, timestamp, and disclaimer.
/// Handles loading, success, cached, and error states with retry button.
class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget>
    with WidgetsBindingObserver {
  WeatherBloc? _weatherBloc;
  Timer? _refreshTimer;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _weatherBloc = context.read<WeatherBloc>();
      _weatherBloc!.add(const LoadWeather());
      _startAutoRefresh();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _weatherBloc?.add(const RefreshWeather()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        switch (state) {
          case WeatherInitial():
          case WeatherLoading():
            return const WeatherWidgetSkeleton();

          case WeatherLoaded():
            return _buildWeatherCard(
              state.weather.temperature,
              state.weather.condition,
              state.weather.icon,
              state.weather.location,
              state.lastUpdated,
              isFromCache: state.isFromCache,
            );

          case WeatherError():
            return _buildErrorCard(
              state.message,
              state.cachedData,
            );
        }
      },
    );
  }

  Widget _buildWeatherCard(
    int temperature,
    String condition,
    String iconCode,
    String location,
    DateTime lastUpdated, {
    bool isFromCache = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Temperature
          Text(
            '$temperature°C',
            style: AppTextStyles.w700s20.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Condition
          Text(
            condition,
            style: AppTextStyles.w500s12.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Icon and location row
          Row(
            children: [
              Icon(
                WeatherIconMapper.mapWeatherIcon(iconCode),
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                location,
                style: AppTextStyles.w400s10.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Timestamp
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${UIStrings.weatherUpdatedPrefix} ${_formatTime(lastUpdated)} WIB',
              style: AppTextStyles.w400s10.copyWith(
                color: AppColors.greyDate,
              ),
            ),
          ),
          // Disclaimer
          const SizedBox(height: AppSpacing.xs),
          Text(
            UIStrings.weatherDisclaimer,
            style: AppTextStyles.w400s10.copyWith(
              color: AppColors.greyDate,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message, WeatherEntity? cachedData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message
          Row(
            children: [
              const Icon(
                Icons.cloud_off,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cachedData != null) ...[
                      Text(
                        UIStrings.weatherCachedPrefix,
                        style: AppTextStyles.w500s10.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    Text(
                      cachedData != null
                          ? UIStrings.weatherUnavailable
                          : message,
                      style: AppTextStyles.w400s10.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Show cached data if available
          if (cachedData != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.greyCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    WeatherIconMapper.mapWeatherIcon(cachedData.icon),
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${cachedData.temperature}°C - ${cachedData.condition}',
                    style: AppTextStyles.w500s12.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // Retry button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _weatherBloc?.add(const RefreshWeather()),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(UIStrings.weatherRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBlue,
                foregroundColor: AppColors.surface,
                minimumSize: const Size(48, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
