import '../../domain/entities/weather_entity.dart';

/// Weather data model for API responses and local storage
///
/// Extends WeatherEntity for easy conversion between layers.
class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.temperature,
    required super.condition,
    required super.icon,
    required super.humidity,
    required super.location,
    required super.timestamp,
  });

  /// Create from JSON response (backend API format)
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['temperature'] as int,
      condition: json['condition'] as String,
      icon: json['icon'] as String,
      humidity: json['humidity'] as int,
      location: json['location'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'icon': icon,
      'humidity': humidity,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert from entity
  factory WeatherModel.fromEntity(WeatherEntity entity) {
    return WeatherModel(
      temperature: entity.temperature,
      condition: entity.condition,
      icon: entity.icon,
      humidity: entity.humidity,
      location: entity.location,
      timestamp: entity.timestamp,
    );
  }

  /// Convert to entity
  WeatherEntity toEntity() {
    return WeatherEntity(
      temperature: temperature,
      condition: condition,
      icon: icon,
      humidity: humidity,
      location: location,
      timestamp: timestamp,
    );
  }
}
