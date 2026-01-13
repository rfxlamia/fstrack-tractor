import 'package:equatable/equatable.dart';

/// Weather Bloc events
sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

/// Initial weather load - shows cached, fetches fresh
class LoadWeather extends WeatherEvent {
  const LoadWeather();
}

/// Force refresh weather data
class RefreshWeather extends WeatherEvent {
  const RefreshWeather();
}
