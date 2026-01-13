import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/core/location/hardcoded_location_provider.dart';
import 'package:fstrack_tractor/features/weather/domain/repositories/weather_repository.dart';
import 'package:fstrack_tractor/features/weather/domain/usecases/get_current_weather_usecase.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_event.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/weather_fixtures.dart';

class MockGetCurrentWeatherUseCase extends Mock
    implements GetCurrentWeatherUseCase {}

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late WeatherBloc weatherBloc;
  late MockGetCurrentWeatherUseCase mockGetCurrentWeatherUseCase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockGetCurrentWeatherUseCase = MockGetCurrentWeatherUseCase();
    mockWeatherRepository = MockWeatherRepository();
    weatherBloc = WeatherBloc(
      getCurrentWeatherUseCase: mockGetCurrentWeatherUseCase,
      weatherRepository: mockWeatherRepository,
      locationProvider: HardcodedLocationProvider(),
    );
  });

  tearDown(() {
    weatherBloc.close();
  });

  group('WeatherBloc', () {
    test('initial state should be WeatherInitial', () {
      expect(weatherBloc.state, const WeatherInitial());
    });

    group('LoadWeather', () {
      blocTest<WeatherBloc, WeatherState>(
        'emits [WeatherLoading, WeatherLoaded] when weather fetch succeeds',
        build: () {
          when(() => mockGetCurrentWeatherUseCase(
                lat: HardcodedLocationProvider.latitude,
                lon: HardcodedLocationProvider.longitude,
              )).thenAnswer((_) async => Right(WeatherFixtures.sunnyWeather));
          return weatherBloc;
        },
        act: (bloc) => bloc.add(const LoadWeather()),
        expect: () => [
          const WeatherLoading(),
          isA<WeatherLoaded>().having(
            (s) => s.weather.temperature,
            'temperature',
            WeatherFixtures.sunnyWeather.temperature,
          ),
        ],
        verify: (_) {
          verify(() => mockGetCurrentWeatherUseCase(
                lat: HardcodedLocationProvider.latitude,
                lon: HardcodedLocationProvider.longitude,
              )).called(1);
        },
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits [WeatherLoading, WeatherError] when weather fetch fails with no cache',
        build: () {
          when(() => mockGetCurrentWeatherUseCase(
                lat: HardcodedLocationProvider.latitude,
                lon: HardcodedLocationProvider.longitude,
              )).thenAnswer(
              (_) async => Left(ServerFailure('Gagal memuat cuaca')));
          when(() => mockWeatherRepository.getCachedWeather())
              .thenAnswer((_) async => null);
          return weatherBloc;
        },
        act: (bloc) => bloc.add(const LoadWeather()),
        expect: () => [
          const WeatherLoading(),
          isA<WeatherError>().having(
            (e) => e.message,
            'message',
            'Gagal memuat cuaca',
          ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits [WeatherLoading, WeatherError with cachedData] when fetch fails but cache exists',
        build: () {
          when(() => mockGetCurrentWeatherUseCase(
                lat: HardcodedLocationProvider.latitude,
                lon: HardcodedLocationProvider.longitude,
              )).thenAnswer((_) async => Left(ServerFailure('Network error')));
          when(() => mockWeatherRepository.getCachedWeather())
              .thenAnswer((_) async => WeatherFixtures.sunnyWeather);
          return weatherBloc;
        },
        act: (bloc) => bloc.add(const LoadWeather()),
        expect: () => [
          const WeatherLoading(),
          isA<WeatherError>()
              .having((e) => e.message, 'message', 'Network error')
              .having((e) => e.cachedData, 'cachedData', isNotNull),
        ],
      );
    });

    group('RefreshWeather', () {
      blocTest<WeatherBloc, WeatherState>(
        'emits [WeatherLoading, WeatherLoaded] when refresh succeeds',
        build: () {
          when(() => mockGetCurrentWeatherUseCase(
                lat: HardcodedLocationProvider.latitude,
                lon: HardcodedLocationProvider.longitude,
              )).thenAnswer((_) async => Right(WeatherFixtures.rainyWeather));
          return weatherBloc;
        },
        act: (bloc) => bloc.add(const RefreshWeather()),
        expect: () => [
          const WeatherLoading(),
          isA<WeatherLoaded>().having(
            (s) => s.weather.condition,
            'condition',
            'hujan',
          ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits [WeatherLoading, WeatherError] when refresh fails',
        build: () {
          when(() => mockGetCurrentWeatherUseCase(
                lat: HardcodedLocationProvider.latitude,
                lon: HardcodedLocationProvider.longitude,
              )).thenAnswer((_) async => Left(ServerFailure('Network error')));
          when(() => mockWeatherRepository.getCachedWeather())
              .thenAnswer((_) async => null);
          return weatherBloc;
        },
        act: (bloc) => bloc.add(const RefreshWeather()),
        expect: () => [
          const WeatherLoading(),
          isA<WeatherError>(),
        ],
      );
    });
  });
}
