import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/hive_service.dart';
import '../models/weather_model.dart';

/// Local data source for weather caching
///
/// Uses existing HiveService for storage with 30-minute TTL.
@injectable
class WeatherLocalDataSource {
  static const String _cacheKey = 'weather_lampung_tengah';

  final HiveService _hiveService;

  WeatherLocalDataSource(this._hiveService);

  /// Get cached weather data
  ///
  /// Returns null if cache expired or not found.
  Future<WeatherModel?> getCachedWeather() async {
    try {
      final data = _hiveService.weatherCacheBox.get(_cacheKey);
      if (data == null) return null;

      final weatherMap = Map<String, dynamic>.from(data as Map);
      final cachedAt = DateTime.parse(weatherMap['cachedAt'] as String);

      if (!_isCacheValid(cachedAt)) {
        // Cache expired, remove it
        await _hiveService.weatherCacheBox.delete(_cacheKey);
        return null;
      }

      return WeatherModel.fromJson(weatherMap['weather'] as Map<String, dynamic>);
    } catch (e) {
      // Invalid cache data
      await _hiveService.weatherCacheBox.delete(_cacheKey);
      return null;
    }
  }

  /// Cache weather data with timestamp
  Future<void> cacheWeather(WeatherModel weather) async {
    await _hiveService.weatherCacheBox.put(_cacheKey, {
      'weather': weather.toJson(),
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Check if cache is still valid
  bool _isCacheValid(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) <
        AppConstants.weatherCacheDuration;
  }
}
