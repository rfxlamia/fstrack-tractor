import 'package:equatable/equatable.dart';

/// Weather entity representing weather data
///
/// Contains temperature, condition, humidity, and location info.
class WeatherEntity extends Equatable {
  final int temperature;
  final String condition;
  final String icon;
  final int humidity;
  final String location;
  final DateTime timestamp;

  const WeatherEntity({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.location,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        temperature,
        condition,
        icon,
        humidity,
        location,
        timestamp,
      ];
}
