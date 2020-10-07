part of masamune.data;

/// Mixin for setting up data documents.
///
/// Override the [createField] method after using it as a [createField].
mixin DataDocumentMixin<TField extends IDataField> on IDocument<TField>
    implements IDataDocument<TField> {
  /// Create a new field.
  ///
  /// [path]: Field path.
  /// [value]: Field value.
  TField createField([String path, dynamic value]);

  /// Get the data.
  ///
  /// Do not use from external class.
  ///
  /// When using from an external class, use getInt or getString.
  ///
  /// [key]: Key for retrieving data.
  @protected
  dynamic operator [](String key) {
    if (!this.data.containsKey(key)) return null;
    return this.data[key]?.data;
  }

  /// Set the data.
  ///
  /// [key]: Key for storing data [value]: Data to store.
  void operator []=(String key, dynamic value) {
    if (value == null) {
      return;
    }
    if (this.isLock) {
      Log.warning("Data modification is prohibited.");
      return;
    }
    if (value is TField) {
      this.set([value]);
    } else {
      if (PathFilter.setTemporary(Paths.child(this.path, key), value)) return;
      if (this.data.containsKey(key) && this.data[key] is IUnit<dynamic>) {
        this.data[key].data = value;
      } else {
        Path path = this.rawPath.clone();
        path.path = Paths.child(this.rawPath.path, key);
        this.set([this.createField(path.path, value)]);
      }
    }
  }

  /// Gets value as Bool.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  @override
  bool getBool(String key, [bool defaultValue = false]) {
    if (isEmpty(key) || !this.data.containsKey(key)) return defaultValue;
    TField data = this.data[key];
    if (data == null) return defaultValue;
    return this.data[key].getBool(defaultValue);
  }

  /// Gets value as Double.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  @override
  double getDouble(String key, [double defaultValue = 0]) {
    if (isEmpty(key) || !this.data.containsKey(key)) return defaultValue;
    TField data = this.data[key];
    if (data == null) return defaultValue;
    return this.data[key].getDouble(defaultValue);
  }

  /// Gets value as Int.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  @override
  int getInt(String key, [int defaultValue = 0]) {
    if (isEmpty(key) || !this.data.containsKey(key)) return defaultValue;
    TField data = this.data[key];
    if (data == null) return defaultValue;
    return this.data[key].getInt(defaultValue);
  }

  /// Gets value as List<T>.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  @override
  List<T> getList<T extends Object>(String key,
      [List<T> defaultValue = const []]) {
    if (isEmpty(key) || !this.data.containsKey(key)) return defaultValue;
    TField data = this.data[key];
    if (data == null) return defaultValue;
    return this.data[key].getList<T>(defaultValue);
  }

  /// Gets value as Map<K,V>.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  @override
  Map<K, V> getMap<K extends Object, V extends Object>(String key,
      [Map<K, V> defaultValue = const {}]) {
    if (isEmpty(key) || !this.data.containsKey(key)) return defaultValue;
    TField data = this.data[key];
    if (data == null) return defaultValue;
    return this.data[key].getMap<K, V>(defaultValue);
  }

  /// Gets value as String.
  ///
  /// [key]: Key for retrieving data.
  /// [defaultValue]: Initial value if there is no value.
  @override
  String getString(String key, [String defaultValue = Const.empty]) {
    if (isEmpty(key) || !this.data.containsKey(key)) return defaultValue;
    TField data = this.data[key];
    if (data == null) return defaultValue;
    return this.data[key].getString(defaultValue);
  }

  /// Get the UID of the document.
  ///
  /// If there is no value in the field, id will be output.
  String get uid => this.getString(Const.uid, this.id);

  /// Get time.
  ///
  /// UpdatedTime is output if the field has no value.
  int get time => this.getInt(Const.time, this.updatedTime);

  /// Update document data.
  Future<T> reload<T extends IDataDocument>() =>
      Future<T>.delayed(Duration.zero);

  /// Save the data.
  ///
  /// Run if you have a remote or need to save data.
  Future<T> save<T extends IDataDocument>() => Future<T>.delayed(Duration.zero);

  /// Delete the data.
  ///
  /// Used when deleting data when there is a remote or when data needs to be saved.
  Future delete() {
    if (this.isDisposed) return Future.delayed(Duration.zero);
    this.dispose();
    return Future.delayed(Duration.zero);
  }
}
