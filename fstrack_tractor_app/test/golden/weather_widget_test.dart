import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/constants/ui_strings.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/core/theme/app_spacing.dart';
import 'package:fstrack_tractor/core/theme/app_text_styles.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/weather/domain/entities/weather_entity.dart';
import 'package:fstrack_tractor/features/weather/presentation/widgets/weather_icon_mapper.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  Widget createGoldenWidget({required Widget body}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(child: body),
      ),
    );
  }

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  group('WeatherWidget Golden Tests', () {
    testGoldens('WeatherWidget displays loaded state', (tester) async {
      final testWeather = WeatherEntity(
        temperature: 28,
        condition: 'berawan',
        icon: '03d',
        humidity: 75,
        location: 'Lampung Tengah',
        timestamp: DateTime.utc(2026, 1, 13, 3, 30, 0),
      );

      final widget = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${testWeather.temperature}°C',
              style: AppTextStyles.w700s20.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              testWeather.condition,
              style: AppTextStyles.w500s12.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  WeatherIconMapper.mapWeatherIcon(testWeather.icon),
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  testWeather.location,
                  style: AppTextStyles.w400s10.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${UIStrings.weatherUpdatedPrefix} ${formatTime(testWeather.timestamp)} WIB',
                style: AppTextStyles.w400s10.copyWith(
                  color: AppColors.greyDate,
                ),
              ),
            ),
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

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: widget),
      );

      await screenMatchesGolden(tester, 'weather_widget_loaded');
    });

    testGoldens('WeatherWidget displays error state without cached data',
        (tester) async {
      const errorMessage = 'Gagal memuat cuaca';

      final widget = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Text(
                        errorMessage,
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
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {},
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

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: widget),
      );

      await screenMatchesGolden(tester, 'weather_widget_error');
    });

    testGoldens('WeatherWidget displays error state with cached data',
        (tester) async {
      final cachedWeather = WeatherEntity(
        temperature: 28,
        condition: 'berawan',
        icon: '03d',
        humidity: 75,
        location: 'Lampung Tengah',
        timestamp: DateTime.utc(2026, 1, 13, 3, 30, 0),
      );

      final widget = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Text(
                        UIStrings.weatherCachedPrefix,
                        style: AppTextStyles.w500s10.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        UIStrings.weatherUnavailable,
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.greyCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    WeatherIconMapper.mapWeatherIcon(cachedWeather.icon),
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${cachedWeather.temperature}°C - ${cachedWeather.condition}',
                    style: AppTextStyles.w500s12.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {},
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

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: widget),
      );

      await screenMatchesGolden(tester, 'weather_widget_error_cached');
    });
  });
}
