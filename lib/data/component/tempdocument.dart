part of masamune.data;

/// Document that stores [TempField] with Key
///
/// Users do n’t really [TempField].
///
/// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
///
/// ```
/// TempDocument document = TempDocument.fromMap(
///   {"A": "Data is A", "B": "Data is B"}
/// );
/// document["A"] // Data is A;
/// document["C"] = "Data is C";
/// ```
class TempDocument extends Document<TempField>
    with DataDocumentMixin<TempField>
    implements IDataDocument<TempField> {
  static Iterable<TempField> _convertData(Map<String, dynamic> data) {
    List<TempField> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      list.add(TempField._withKey(key, value));
    });
    return list;
  }

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      TempDocument._() as T;

  /// Document that stores [TempField] with Key
  ///
  /// Users do n’t really [TempField].
  ///
  /// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
  ///
  /// ```
  /// TempDocument document = TempDocument.fromMap(
  ///   {"A": "Data is A", "B": "Data is B"}
  /// );
  /// document["A"] // Data is A;
  /// document["C"] = "Data is C";
  /// ```
  factory TempDocument() {
    return TempDocument._();
  }

  /// Document that stores [TempField] with Key
  ///
  /// Users do n’t really [TempField].
  ///
  /// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
  ///
  /// ```
  /// TempDocument document = TempDocument.fromMap(
  ///   {"A": "Data is A", "B": "Data is B"}
  /// );
  /// document["A"] // Data is A;
  /// document["C"] = "Data is C";
  /// ```
  ///
  /// [jsonData]: Json string representing Map.
  factory TempDocument.fromJson(String jsonData) {
    Map<String, dynamic> data = Json.decodeAsMap(jsonData);
    return TempDocument.fromMap(data);
  }

  /// Document that stores [TempField] with Key
  ///
  /// Users do n’t really [TempField].
  ///
  /// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
  ///
  /// ```
  /// TempDocument document = TempDocument.fromMap(
  ///   {"A": "Data is A", "B": "Data is B"}
  /// );
  /// document["A"] // Data is A;
  /// document["C"] = "Data is C";
  /// ```
  ///
  /// [mapData]: Map data to be stored.
  factory TempDocument.fromMap(Map<String, dynamic> mapData) {
    return TempDocument._(children: _convertData(mapData));
  }
  factory TempDocument._fromMapWithKey(
      String path, Map<String, dynamic> mapData) {
    return TempDocument._(path: path, children: _convertData(mapData));
  }
  TempDocument._({String path, Iterable<TempField> children})
      : super(null, children: children, isTemporary: true);

  /// Processing to set a value.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: Value to set.
  @protected
  void setInternal(TempField value) {
    if (value == null) return;
    String key = value.id;
    if (isEmpty(key)) key = Texts.uuid;
    if (this.data.containsKey(key)) {
      if (value != this.data[key]) value.copyTo(this.data[key]);
    } else {
      this.data[key] = value;
    }
    this.notifyUpdate(value.updatedTime);
  }

  /// Processing to delete values.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: The value to remove.
  @protected
  void unsetInternal(TempField value) {
    if (value == null) return;
    if (!this.data.containsKey(value.id)) return;
    value?.dispose();
    this.data.remove(value.id);
    this.notifyUpdate();
  }

  /// Register the temporary data in the path map.
  ///
  /// Not registered if the protocol is temporary.
  @protected
  void registerUntemporary() {
    throw UnimplementedError("This object cannot be Untemporary.");
  }

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.tmp;

  /// True if the object is temporary data.
  @override
  bool get isTemporary => true;

  /// Create a new field.
  ///
  /// [path]: Field path.
  /// [value]: Field value.
  @override
  TempField createField([String path, value]) =>
      TempField._withKey(path, value);
}
