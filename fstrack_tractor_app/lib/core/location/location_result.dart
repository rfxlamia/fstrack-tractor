/// Location result data class
///
/// Contains the location coordinates and optional name.
class LocationResult {
  final double latitude;
  final double longitude;
  final String? name;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationResult &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, name);
}
