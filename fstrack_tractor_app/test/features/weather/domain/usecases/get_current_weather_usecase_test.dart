import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/features/weather/domain/repositories/weather_repository.dart';
import 'package:fstrack_tractor/features/weather/domain/usecases/get_current_weather_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/weather_fixtures.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late GetCurrentWeatherUseCase useCase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    useCase = GetCurrentWeatherUseCase(mockWeatherRepository);
  });

  group('GetCurrentWeatherUseCase', () {
    const testLat = -4.8357;
    const testLon = 105.0273;

    test('should return cached weather when cache is valid', () async {
      // Arrange
      final cachedWeather = WeatherFixtures.sunnyWeather;
      when(mockWeatherRepository.getCachedWeather)
          .thenAnswer((_) async => cachedWeather);
      when(() => mockWeatherRepository.getCurrentWeather(testLat, testLon))
          .thenAnswer((_) async => Right(WeatherFixtures.rainyWeather));

      // Act
      final result = await useCase(lat: testLat, lon: testLon);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right, got Left with $failure'),
        (weather) {
          expect(weather.temperature, cachedWeather.temperature);
          expect(weather.condition, cachedWeather.condition);
        },
      );
      verify(mockWeatherRepository.getCachedWeather).called(1);
      verify(() => mockWeatherRepository.getCurrentWeather(testLat, testLon)).called(1);
    });

    test('should fetch from API when cache is null', () async {
      // Arrange
      final freshWeather = WeatherFixtures.clearWeather;
      when(mockWeatherRepository.getCachedWeather)
          .thenAnswer((_) async => null);
      when(() => mockWeatherRepository.getCurrentWeather(testLat, testLon))
          .thenAnswer((_) async => Right(freshWeather));

      // Act
      final result = await useCase(lat: testLat, lon: testLon);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right, got Left with $failure'),
        (weather) {
          expect(weather.temperature, freshWeather.temperature);
          expect(weather.icon, freshWeather.icon);
        },
      );
      verify(mockWeatherRepository.getCachedWeather).called(1);
      verify(() => mockWeatherRepository.getCurrentWeather(testLat, testLon))
          .called(1);
    });

    test('should return ServerFailure when API fails with no cache', () async {
      // Arrange
      when(mockWeatherRepository.getCachedWeather)
          .thenAnswer((_) async => null);
      when(() => mockWeatherRepository.getCurrentWeather(testLat, testLon))
          .thenAnswer((_) async => Left(ServerFailure('Gagal memuat cuaca')));

      // Act
      final result = await useCase(lat: testLat, lon: testLon);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Gagal memuat cuaca');
        },
        (weather) => fail('Expected Left, got Right'),
      );
    });

    test('should return cached weather even when API fails', () async {
      // Arrange
      final cachedWeather = WeatherFixtures.sunnyWeather;
      when(mockWeatherRepository.getCachedWeather)
          .thenAnswer((_) async => cachedWeather);
      when(() => mockWeatherRepository.getCurrentWeather(testLat, testLon))
          .thenAnswer((_) async => Left(ServerFailure('Network error')));

      // Act
      final result = await useCase(lat: testLat, lon: testLon);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right, got Left with $failure'),
        (weather) {
          expect(weather.temperature, cachedWeather.temperature);
          expect(weather.condition, cachedWeather.condition);
        },
      );
    });
  });
}
