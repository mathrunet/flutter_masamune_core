part of masamune.data;

/// Stores location data.
///
/// Please inherit and use it.
@immutable
abstract class GeoData {
  /// Latitude.
  double get latitude;

  /// Longitude.
  double get longitude;

  /// Calculate the distance between two points.
  ///
  /// [data]: GeoData.
  double distance(GeoData data);

  /// Stores location data.
  ///
  /// Please inherit and use it.
  const GeoData();
}
