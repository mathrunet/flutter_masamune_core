part of masamune.data;

/// Document that stores [TemporaryField] with Key
///
/// Users do n’t really [TemporaryField].
///
/// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
///
/// ```
/// TemporaryDocument document = TemporaryDocument.fromMap(
///   {"A": "Data is A", "B": "Data is B"}
/// );
/// document["A"] // Data is A;
/// document["C"] = "Data is C";
/// ```
class TemporaryDocument extends Document<TemporaryField>
    with DataDocumentMixin<TemporaryField>
    implements IDataDocument<TemporaryField> {
  static Iterable<TemporaryField> _convertData(Map<String, dynamic> data) {
    List<TemporaryField> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      list.add(TemporaryField._withKey(key, value));
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
      TemporaryDocument._() as T;

  /// Document that stores [TemporaryField] with Key
  ///
  /// Users do n’t really [TemporaryField].
  ///
  /// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
  ///
  /// ```
  /// TemporaryDocument document = TemporaryDocument.fromMap(
  ///   {"A": "Data is A", "B": "Data is B"}
  /// );
  /// document["A"] // Data is A;
  /// document["C"] = "Data is C";
  /// ```
  factory TemporaryDocument() {
    return TemporaryDocument._();
  }

  /// Document that stores [TemporaryField] with Key
  ///
  /// Users do n’t really [TemporaryField].
  ///
  /// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
  ///
  /// ```
  /// TemporaryDocument document = TemporaryDocument.fromMap(
  ///   {"A": "Data is A", "B": "Data is B"}
  /// );
  /// document["A"] // Data is A;
  /// document["C"] = "Data is C";
  /// ```
  ///
  /// [jsonData]: Json string representing Map.
  factory TemporaryDocument.fromJson(String jsonData) {
    Map<String, dynamic> data = Json.decodeAsMap(jsonData);
    return TemporaryDocument.fromMap(data);
  }

  /// Document that stores [TemporaryField] with Key
  ///
  /// Users do n’t really [TemporaryField].
  ///
  /// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
  ///
  /// ```
  /// TemporaryDocument document = TemporaryDocument.fromMap(
  ///   {"A": "Data is A", "B": "Data is B"}
  /// );
  /// document["A"] // Data is A;
  /// document["C"] = "Data is C";
  /// ```
  ///
  /// [mapData]: Map data to be stored.
  factory TemporaryDocument.fromMap(Map<String, dynamic> mapData) {
    return TemporaryDocument._(children: _convertData(mapData));
  }
  factory TemporaryDocument._fromMapWithKey(
      String path, Map<String, dynamic> mapData) {
    return TemporaryDocument._(path: path, children: _convertData(mapData));
  }
  TemporaryDocument._({String path, Iterable<TemporaryField> children})
      : super(null, children: children, isTemporary: true);

  /// Processing to set a value.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: Value to set.
  @protected
  void setInternal(TemporaryField value) {
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
  void unsetInternal(TemporaryField value) {
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
  TemporaryField createField([String path, value]) =>
      TemporaryField._withKey(path, value);
}
