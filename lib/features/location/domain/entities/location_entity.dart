/// Pure Dart Location Entity.
/// ABSOLUTELY NO package:flutter imports allowed here.
class LocationEntity {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationEntity &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          accuracy == other.accuracy &&
          speed == other.speed &&
          heading == other.heading &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      accuracy.hashCode ^
      speed.hashCode ^
      heading.hashCode ^
      timestamp.hashCode;

  @override
  String toString() =>
      'LocationEntity(lat: $latitude, lng: $longitude, accuracy: $accuracy, timestamp: $timestamp)';
}
