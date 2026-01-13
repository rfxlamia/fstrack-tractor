import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/error/exceptions.dart';
import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/features/weather/data/datasources/weather_local_datasource.dart';
import 'package:fstrack_tractor/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:fstrack_tractor/features/weather/data/models/weather_model.dart';
import 'package:fstrack_tractor/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockWeatherRemoteDataSource extends Mock
    implements WeatherRemoteDataSource {}

class MockWeatherLocalDataSource extends Mock
    implements WeatherLocalDataSource {}

class FakeWeatherModel extends Fake implements WeatherModel {}

void main() {
  late WeatherRepositoryImpl repository;
  late MockWeatherRemoteDataSource mockRemoteDataSource;
  late MockWeatherLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeWeatherModel());
  });

  setUp(() {
    mockRemoteDataSource = MockWeatherRemoteDataSource();
    mockLocalDataSource = MockWeatherLocalDataSource();
    repository = WeatherRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('WeatherRepositoryImpl', () {
    const testLat = -4.8357;
    const testLon = 105.0273;

    final testWeatherModel = WeatherModel(
      temperature: 28,
      condition: 'berawan',
      icon: '03d',
      humidity: 75,
      location: 'Lampung Tengah',
      timestamp: DateTime(2026, 1, 13, 10, 30),
    );

    group('getCurrentWeather', () {
      test('should return weather entity when remote call succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.getCurrentWeather(
              lat: testLat,
              lon: testLon,
            )).thenAnswer((_) async => testWeatherModel);
        when(() => mockLocalDataSource.cacheWeather(testWeatherModel))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getCurrentWeather(testLat, testLon);

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right, got Left with $failure'),
          (weather) {
            expect(weather.temperature, testWeatherModel.temperature);
            expect(weather.condition, testWeatherModel.condition);
          },
        );
        verify(() => mockRemoteDataSource.getCurrentWeather(
              lat: testLat,
              lon: testLon,
            )).called(1);
        verify(() => mockLocalDataSource.cacheWeather(testWeatherModel))
            .called(1);
      });

      test('should cache weather data when remote call succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.getCurrentWeather(
              lat: testLat,
              lon: testLon,
            )).thenAnswer((_) async => testWeatherModel);
        when(() => mockLocalDataSource.cacheWeather(testWeatherModel))
            .thenAnswer((_) async {});

        // Act
        await repository.getCurrentWeather(testLat, testLon);

        // Assert
        verify(() => mockLocalDataSource.cacheWeather(testWeatherModel))
            .called(1);
      });

      test('should return ServerFailure when remote call throws ServerException',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.getCurrentWeather(
              lat: testLat,
              lon: testLon,
            )).thenThrow(ServerException('Gagal memuat cuaca'));

        // Act
        final result = await repository.getCurrentWeather(testLat, testLon);

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

      test('should return ServerFailure when remote call throws generic exception',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.getCurrentWeather(
              lat: testLat,
              lon: testLon,
            )).thenThrow(Exception('Unknown error'));

        // Act
        final result = await repository.getCurrentWeather(testLat, testLon);

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Gagal memuat data cuaca');
          },
          (weather) => fail('Expected Left, got Right'),
        );
      });
    });

    group('getCachedWeather', () {
      test('should return cached weather from local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedWeather())
            .thenAnswer((_) async => testWeatherModel);

        // Act
        final result = await repository.getCachedWeather();

        // Assert
        expect(result, isNotNull);
        expect(result!.temperature, testWeatherModel.temperature);
        verify(() => mockLocalDataSource.getCachedWeather()).called(1);
      });

      test('should return null when no cached weather exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedWeather())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCachedWeather();

        // Assert
        expect(result, isNull);
      });
    });

    group('cacheWeather', () {
      test('should call local data source to cache weather', () async {
        // Arrange
        when(() => mockLocalDataSource.cacheWeather(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.cacheWeather(testWeatherModel.toEntity());

        // Assert
        verify(() => mockLocalDataSource.cacheWeather(any())).called(1);
      });
    });
  });
}
