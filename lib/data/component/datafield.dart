part of masamune.data;

/// Unit for storing data.
///
/// Store data by specifying path and value.
///
/// If you omit the path, the UUID is set as the path.
///
/// If the path already exists in the pathmap, get the data from the pathmap.
///
/// ```
/// DataField data = DataField( "tmp/data", "text" );
/// ```
class DataField extends Unit implements IDataField {
  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      DataField._(path: path, isTemporary: isTemporary) as T;

  /// Unit for storing data.
  ///
  /// Store data by specifying path and value.
  ///
  /// If you omit the path, the UUID is set as the path.
  ///
  /// If the path already exists in the pathmap, get the data from the pathmap.
  ///
  /// ```
  /// DataField data = DataField( "tmp/data", "text" );
  /// ```
  ///
  /// [path]: Data path.
  /// [value]: Data value.
  factory DataField([String path, dynamic value]) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    DataField unit = PathMap.get<DataField>(path);
    if (unit != null) {
      if (value != null) unit.data = value;
      return unit;
    }
    return DataField._(path: path, value: value);
  }
  DataField._({String path, dynamic value, bool isTemporary = false})
      : super(path, value: value, isTemporary: isTemporary);

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.data;

  /// Gets value as Bool.
  ///
  /// [defaultValue]: Initial value if there is no value.
  @override
  bool getBool([bool defaultValue = false]) {
    if (this.data == null) return defaultValue;
    switch (this.data.runtimeType) {
      case bool:
        return this.data;
      case int:
        return this.data != 0;
      case double:
        return this.data != 0;
      case String:
        return this.data.asString.toBool();
    }
    return defaultValue;
  }

  /// Gets value as Double.
  ///
  /// [defaultValue]: Initial value if there is no value.
  @override
  double getDouble([double defaultValue = 0]) {
    if (this.data == null) return defaultValue;
    switch (this.data.runtimeType) {
      case int:
        return this.data.asInt.toDouble();
      case double:
        return this.data;
      case String:
        return this.data.asString.toDouble();
    }
    return defaultValue;
  }

  /// Gets value as Int.
  ///
  /// [defaultValue]: Initial value if there is no value.
  @override
  int getInt([int defaultValue = 0]) {
    if (this.data == null) return defaultValue;
    switch (this.data.runtimeType) {
      case int:
        return this.data.asInt;
      case double:
        return this.data.asDouble.round();
      case String:
        return this.data.asString.toInt();
    }
    return defaultValue;
  }

  /// Gets value as List<T>.
  ///
  /// [defaultValue]: Initial value if there is no value.
  @override
  List<T> getList<T extends Object>([List<T> defaultValue]) {
    if (this.data == null) return defaultValue;
    if (this.data is List<T>) return this.data;
    if (this.data is List) return (this.data as List).cast<T>();
    return defaultValue;
  }

  /// Gets value as Map<K,V>.
  ///
  /// [defaultValue]: Initial value if there is no value.
  @override
  Map<K, V> getMap<K extends Object, V extends Object>(
      [Map<K, V> defaultValue]) {
    if (this.data == null) return defaultValue;
    if (this.data is Map<K, V>) return this.data;
    if (this.data is Map) return (this.data as Map).cast<K, V>();
    return defaultValue;
  }

  /// Gets value as GeoData.
  ///
  /// [defaultValue]: Initial value if there is no value.
  @override
  T getGeo<T extends GeoData>([T defaultValue]) {
    if (this.data == null) return defaultValue;
    if (this.data is T) return this.data;
    return defaultValue;
  }

  /// Gets value as String.
  ///
  /// [defaultValue]: Initial value if there is no value.
  @override
  String getString([String defaultValue]) {
    if (this.data == null) return defaultValue;
    return this.data.toString();
  }
}
