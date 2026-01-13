import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/location/location_provider.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';
import 'weather_event.dart';
import 'weather_state.dart';

/// Weather Bloc - manages weather data state for the widget
///
/// Handles loading, caching, and refresh operations.
@injectable
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetCurrentWeatherUseCase _getCurrentWeatherUseCase;
  final WeatherRepository _weatherRepository;
  final LocationProvider _locationProvider;

  WeatherBloc({
    required GetCurrentWeatherUseCase getCurrentWeatherUseCase,
    required WeatherRepository weatherRepository,
    required LocationProvider locationProvider,
  })  : _getCurrentWeatherUseCase = getCurrentWeatherUseCase,
        _weatherRepository = weatherRepository,
        _locationProvider = locationProvider,
        super(const WeatherInitial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    on<LoadWeather>(_handleLoadWeather);
    on<RefreshWeather>(_handleRefreshWeather);
  }

  Future<void> _handleLoadWeather(
    LoadWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    final location = await _locationProvider.getCurrentLocation();

    final result = await _getCurrentWeatherUseCase(
      lat: location.latitude,
      lon: location.longitude,
    );

    await result.fold(
      (failure) async {
        await _handleErrorWithCache(failure, emit);
      },
      (weather) async {
        emit(WeatherLoaded(
          weather: weather,
          lastUpdated: weather.timestamp,
          isFromCache: false,
        ));
      },
    );
  }

  Future<void> _handleRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    final location = await _locationProvider.getCurrentLocation();

    final result = await _getCurrentWeatherUseCase(
      lat: location.latitude,
      lon: location.longitude,
    );

    await result.fold(
      (failure) async {
        await _handleErrorWithCache(failure, emit);
      },
      (weather) async {
        emit(WeatherLoaded(
          weather: weather,
          lastUpdated: DateTime.now(),
          isFromCache: false,
        ));
      },
    );
  }

  Future<void> _handleErrorWithCache(
    dynamic failure,
    Emitter<WeatherState> emit,
  ) async {
    // Get cached data directly from repository (no network call)
    final cached = await _weatherRepository.getCachedWeather();

    if (cached != null) {
      emit(WeatherError(
        message: failure.message ?? 'Gagal memuat cuaca',
        cachedData: cached,
      ));
    } else {
      emit(WeatherError(
        message: failure.message ?? 'Gagal memuat cuaca',
      ));
    }
  }
}
