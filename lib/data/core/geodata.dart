part of masamune.data;

/// Stores location data.
///
/// Please inherit and use it.
@immutable
class GeoData {
  /// Latitude.
  double get latitude => 0;

  /// Longitude.
  double get longitude => 0;

  /// Location name.
  String get name => Const.empty;

  /// Hash of [GeoData].
  String get hash => Const.empty;

  /// All neighbors of [GeoData].
  List<String> get neighbors => const [];

  /// Calculate the distance between two points.
  ///
  /// [data]: GeoData.
  double distance(GeoData data) => 0;

  /// Stores location data.
  ///
  /// Please inherit and use it.
  const GeoData();

  /// Returns a string representation of this object.
  @override
  String toString() {
    if (isNotEmpty(this.name)) return this.name;
    return "$latitude,$longitude";
  }
}
