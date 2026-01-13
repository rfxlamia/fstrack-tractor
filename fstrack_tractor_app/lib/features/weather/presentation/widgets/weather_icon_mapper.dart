import 'package:flutter/material.dart';

/// Weather icon mapping utility
///
/// Maps OpenWeatherMap icon codes to Material Icons.
class WeatherIconMapper {
  /// Map icon code to Material icon
  static IconData mapWeatherIcon(String code) {
    return switch (code) {
      '01d' || '01n' => Icons.wb_sunny, // Clear
      '02d' || '02n' => Icons.cloud, // Few clouds
      '03d' || '03n' => Icons.cloud, // Scattered clouds
      '04d' || '04n' => Icons.cloud_queue, // Broken clouds
      '09d' || '09n' => Icons.grain, // Shower rain
      '10d' || '10n' => Icons.beach_access, // Rain
      '11d' || '11n' => Icons.flash_on, // Thunderstorm
      '13d' || '13n' => Icons.ac_unit, // Snow
      '50d' || '50n' => Icons.blur_on, // Mist
      _ => Icons.cloud_off, // Unknown
    };
  }
}
