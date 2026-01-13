import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

/// Use case for getting current weather
///
/// Orchestrates cache-first strategy: return cached immediately,
/// fetch fresh in background, update if new data available.
@injectable
class GetCurrentWeatherUseCase {
  final WeatherRepository _weatherRepository;

  GetCurrentWeatherUseCase(this._weatherRepository);

  Future<Either<Failure, WeatherEntity>> call({
    required double lat,
    required double lon,
  }) async {
    // Try cache first
    final cached = await _weatherRepository.getCachedWeather();
    if (cached != null) {
      // Return cached immediately, fetch fresh in background
      _refreshInBackground(lat, lon);
      return Right(cached);
    }

    // No cache, fetch from API
    return _weatherRepository.getCurrentWeather(lat, lon);
  }

  Future<void> _refreshInBackground(double lat, double lon) async {
    try {
      final result = await _weatherRepository.getCurrentWeather(lat, lon);
      result.fold(
        (failure) {
          // Silently fail - we already have cached data
        },
        (weather) {
          // Update cache with fresh data
          _weatherRepository.cacheWeather(weather);
        },
      );
    } catch (_) {
      // Silently fail background refresh
    }
  }
}
