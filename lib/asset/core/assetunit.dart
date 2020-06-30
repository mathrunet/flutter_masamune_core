part of masamune.asset;

/// Abstract class for handling assets.
///
/// Acquire images, video, and audio from
/// network, local, etc. and save assets as data.
abstract class AssetUnit<T extends Object> extends TaskUnit<T>
    implements IAsset {
  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.file;

  /// Abstract class for handling assets.
  ///
  /// Acquire images, video, and audio from
  /// network, local, etc. and save assets as data.
  ///
  /// [value]: Asset value.
  /// [isTemporary]: True if it is temporary data.
  /// [group]: Asset group (0 or more).
  /// [order]: Asset order.
  AssetUnit(
      {String path, bool isTemporary = false, int order = 10, int group = 0})
      : super(path: path, isTemporary: isTemporary, order: order, group: group);
}
