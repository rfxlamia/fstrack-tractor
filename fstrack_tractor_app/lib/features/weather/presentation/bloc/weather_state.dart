import 'package:equatable/equatable.dart';

import '../../domain/entities/weather_entity.dart';

/// Weather Bloc states
sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// Loading state
class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

/// Weather loaded successfully
class WeatherLoaded extends WeatherState {
  final WeatherEntity weather;
  final DateTime lastUpdated;
  final bool isFromCache;

  const WeatherLoaded({
    required this.weather,
    required this.lastUpdated,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [weather, lastUpdated, isFromCache];
}

/// Error state - can still show cached data
class WeatherError extends WeatherState {
  final String message;
  final WeatherEntity? cachedData;

  const WeatherError({
    required this.message,
    this.cachedData,
  });

  @override
  List<Object?> get props => [message, cachedData];
}
