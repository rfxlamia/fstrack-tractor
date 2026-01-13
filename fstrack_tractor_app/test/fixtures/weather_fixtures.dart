import 'package:fstrack_tractor/features/weather/domain/entities/weather_entity.dart';

/// Test fixtures for Weather entity
class WeatherFixtures {
  static final sunnyWeather = WeatherEntity(
        temperature: 28,
        condition: 'berawan',
        icon: '03d',
        humidity: 75,
        location: 'Lampung Tengah',
        timestamp: DateTime(2026, 1, 13, 10, 30),
      );

  static final rainyWeather = WeatherEntity(
        temperature: 24,
        condition: 'hujan',
        icon: '10d',
        humidity: 90,
        location: 'Lampung Tengah',
        timestamp: DateTime(2026, 1, 13, 14, 0),
      );

  static final clearWeather = WeatherEntity(
        temperature: 32,
        condition: 'cerah',
        icon: '01d',
        humidity: 60,
        location: 'Lampung Tengah',
        timestamp: DateTime(2026, 1, 13, 12, 0),
      );

  static Map<String, dynamic> weatherJson() => {
        'temperature': 28,
        'condition': 'berawan',
        'icon': '03d',
        'humidity': 75,
        'location': 'Lampung Tengah',
        'timestamp': '2026-01-13T10:30:00.000Z',
      };
}
