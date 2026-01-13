import 'location_result.dart';

/// Location provider interface
///
/// Provides current location coordinates for weather data.
/// Future-ready for GPS-based location (post-MVP).
abstract class LocationProvider {
  /// Get current location coordinates
  Future<LocationResult> getCurrentLocation();
}
