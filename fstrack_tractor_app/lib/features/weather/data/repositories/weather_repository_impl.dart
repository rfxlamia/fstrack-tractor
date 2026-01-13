import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_datasource.dart';
import '../datasources/weather_remote_datasource.dart';
import '../models/weather_model.dart';

/// Implementation of WeatherRepository
///
/// Handles weather data fetching with cache-first strategy.
@LazySingleton(as: WeatherRepository)
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;
  final WeatherLocalDataSource _localDataSource;

  WeatherRepositoryImpl({
    required WeatherRemoteDataSource remoteDataSource,
    required WeatherLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    double lat,
    double lon,
  ) async {
    try {
      final weather = await _remoteDataSource.getCurrentWeather(
        lat: lat,
        lon: lon,
      );
      // Cache the fresh data
      await _localDataSource.cacheWeather(weather);
      return Right(weather.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memuat data cuaca'));
    }
  }

  @override
  Future<WeatherEntity?> getCachedWeather() async {
    return _localDataSource.getCachedWeather();
  }

  @override
  Future<void> cacheWeather(WeatherEntity weather) async {
    await _localDataSource.cacheWeather(WeatherModel.fromEntity(weather));
  }
}
