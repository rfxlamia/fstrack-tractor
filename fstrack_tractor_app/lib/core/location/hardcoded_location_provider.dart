import 'package:injectable/injectable.dart';

import 'location_provider.dart';
import 'location_result.dart';

/// Hardcoded location provider for Lampung Tengah
///
/// Uses fixed coordinates for MVP. Future GPS support
/// will replace this with actual device location.
@Injectable(as: LocationProvider)
class HardcodedLocationProvider implements LocationProvider {
  static const double latitude = -4.8357; // Lampung Tengah
  static const double longitude = 105.0273;
  static const String locationName = 'Lampung Tengah';

  @override
  Future<LocationResult> getCurrentLocation() async {
    return const LocationResult(
      latitude: latitude,
      longitude: longitude,
      name: locationName,
    );
  }
}
