part of masamune.data;

/// Stores location data.
///
/// Please inherit and use it.
@immutable
class GeoData {
  static const double _r = 6378.137;

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
  double distance(GeoData data) {
    final y2 = pi * data.longitude / 180.0;
    final y1 = pi * this.longitude / 180.0;
    final x2 = pi * data.latitude / 180.0;
    final x1 = pi * this.latitude / 180.0;
    return _r * acos(sin(y1) * sin(y2) + cos(y1) * cos(y2) * cos(x2 - x1));
  }

  /// Calculate the direction between tow points.
  ///
  /// [target]: Target geoData.
  double direction(GeoData target) {
    final y2 = pi * target.longitude / 180.0;
    final y1 = pi * this.longitude / 180.0;
    final x2 = pi * target.latitude / 180.0;
    final x1 = pi * this.latitude / 180.0;
    final w = 180 *
        atan2(
          sin(x2 - x1),
          cos(y1) * tan(y2) - sin(y1) * cos(x2 - x1),
        ) /
        pi;
    return w - 90;
  }

  /// Stores location data.
  ///
  /// Please inherit and use it.
  const GeoData();

  /// Returns a string representation of this object.
  @override
  String toString() {
    return "${this.name ?? ""}[$latitude° N,$longitude° E]";
  }
}
