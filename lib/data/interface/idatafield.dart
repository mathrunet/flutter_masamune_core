part of masamune.data;

/// Interface for saving data.
///
/// Since it inherits Unit, it can be included in Document and Collection.
///
/// Please implement and use.
abstract class IDataField implements IUnit {
  /// Gets value as Int.
  ///
  /// [defaultValue]: Initial value if there is no value.
  int getInt([int defaultValue = 0]);

  /// Gets value as Double.
  ///
  /// [defaultValue]: Initial value if there is no value.
  double getDouble([double defaultValue = 0]);

  /// Gets value as Bool.
  ///
  /// [defaultValue]: Initial value if there is no value.
  bool getBool([bool defaultValue = false]);

  /// Gets value as String.
  ///
  /// [defaultValue]: Initial value if there is no value.
  String getString([String defaultValue]);

  /// Gets value as List<T>.
  ///
  /// [defaultValue]: Initial value if there is no value.
  List<T> getList<T extends Object>([List<T> defaultValue]);

  /// Gets value as Map<K,V>.
  ///
  /// [defaultValue]: Initial value if there is no value.
  Map<K, V> getMap<K extends Object, V extends Object>(
      [Map<K, V> defaultValue]);
}
