part of masamune.path;

/// Interface for defining the data part of the path.
///
/// Please implement and use.
abstract class IUnit<TValue extends Object>
    implements IPath, IChild, IDebuggable {
  /// Get the data.
  TValue get data;

  /// Set the data.
  ///
  /// [value]: Data to set.
  set data(TValue value);

  /// Get the raw data.
  TValue get rawData;

  /// When map data is stored.
  ///
  /// You can get the data by specifying the path.
  ///
  /// [path]: The path to get the data.
  dynamic operator [](String path);

  /// Processing to set a value.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: Value to set.
  @protected
  void setInternal(TValue value);

  /// Processing to delete values.
  ///
  /// Do not use from outside the class.
  @protected
  void unsetInternal();
}
