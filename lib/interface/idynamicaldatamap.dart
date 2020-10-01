part of masamune.interface;

/// Interface for input and output of [dynamic] data.
///
/// At the time of input, you can enter the data in any direction,
/// and use the [get] method to get the data at the time of output.
abstract class IDynamicalDataMap {
  /// Get the data.
  ///
  /// Do not use from external class.
  ///
  /// When using from an external class, use getInt or getString.
  ///
  /// [key]: Key for retrieving data.
  @protected
  dynamic operator [](String key);

  /// Set the data.
  ///
  /// [key]: Key for storing data.
  /// [value]: Data to store.
  void operator []=(String key, dynamic value);

  /// Gets value as Int.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  int getInt(String key, [int defaultValue = 0]);

  /// Gets value as Double.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  double getDouble(String key, [double defaultValue = 0]);

  /// Gets value as Bool.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  bool getBool(String key, [bool defaultValue = false]);

  /// Gets value as String.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  String getString(String key, [String defaultValue = Const.empty]);

  /// Gets value as List<T>.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  List<T> getList<T extends Object>(String key,
      [List<T> defaultValue = const []]);

  /// Gets value as Map<K,V>.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  Map<K, V> getMap<K extends Object, V extends Object>(String key,
      [Map<K, V> defaultValue = const {}]);

  /// Get number of documents.
  int get length;

  /// Get the document key list.
  Iterable<String> get keys;

  /// Check if the document contains a key.
  ///
  /// True if key is included.
  ///
  /// [key]: Key to check.
  bool containsKey(String key);

  /// Remove data from document.
  ///
  /// [key]: Key to delete.
  void remove(String key);

  /// Remove data from document.
  ///
  /// [keys]: Keys to delete.
  void removeAll(Iterable<String> keys);

  /// Remove all data from the document.
  void clear();
}
