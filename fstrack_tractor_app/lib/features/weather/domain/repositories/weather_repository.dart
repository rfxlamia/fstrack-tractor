import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/weather_entity.dart';

/// Repository interface for weather operations
///
/// Follows Clean Architecture - domain layer defines interface,
/// data layer provides implementation.
abstract class WeatherRepository {
  /// Get current weather for given coordinates
  ///
  /// Returns Either<Failure, WeatherEntity> for error handling
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    double lat,
    double lon,
  );

  /// Get cached weather data if available
  ///
  /// Returns null if no cache exists or cache is expired
  Future<WeatherEntity?> getCachedWeather();

  /// Cache weather data with timestamp
  Future<void> cacheWeather(WeatherEntity weather);
}
