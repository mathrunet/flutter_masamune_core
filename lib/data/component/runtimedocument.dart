part of masamune.data;

/// Document that stores [DataField] with Key
///
/// Users do n’t really [DataField].
///
/// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
///
/// ```
/// RuntimeDocument document = RuntimeDocument.fromMap(
///   "data/document", {"A": "Data is A", "B": "Data is B"}
/// );
/// document["A"] // Data is A;
/// document["C"] = "Data is C";
/// ```
class RuntimeDocument extends Document<DataField>
    with DataDocumentMixin<DataField>
    implements IDataDocument<DataField> {
  static Iterable<DataField> _convertData(
      String path, Map<String, dynamic> data) {
    List<DataField> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      if (value is DataField) {
        String child = Paths.child(path, key);
        if (value.path == child)
          list.add(value);
        else
          list.add(value.clone(path: child, isTemporary: false));
      } else {
        list.add(DataField(Paths.child(path, key), value));
      }
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
      RuntimeDocument._(path: path, isTemporary: isTemporary) as T;

  /// Document that stores [DataField] with Key.
  ///
  /// Users do n’t really [DataField].
  ///
  /// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
  ///
  /// ```
  /// RuntimeDocument document = RuntimeDocument.fromMap(
  ///   "data/document", {"A": "Data is A", "B": "Data is B"}
  /// );
  /// document["A"] // Data is A;
  /// document["C"] = "Data is C";
  /// ```
  ///
  /// [path]: Document path. If empty, a UUID will be assigned.
  factory RuntimeDocument(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    RuntimeDocument document = PathMap.get<RuntimeDocument>(path);
    if (document != null) return document;
    return RuntimeDocument._(path: path);
  }

  /// Document that stores [DataField] with Key.
  ///
  /// Users do n’t really [DataField].
  ///
  /// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
  ///
  /// ```
  /// RuntimeDocument document = RuntimeDocument.fromMap(
  ///   "data/document", {"A": "Data is A", "B": "Data is B"}
  /// );
  /// document["A"] // Data is A;
  /// document["C"] = "Data is C";
  /// ```
  ///
  /// [path]: Document path. If empty, a UUID will be assigned.
  /// [jsonData]: Json string representing Map.
  factory RuntimeDocument.fromJson(String path, String jsonData) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    Map<String, dynamic> data = Json.decodeAsMap(jsonData);
    if (data == null) return RuntimeDocument(path);
    return RuntimeDocument.fromMap(path, data);
  }

  /// Document that stores [DataField] with Key.
  ///
  /// Users do n’t really [DataField].
  ///
  /// Normal, Can be treated as if the data were handled [Map<String, dynamic>].
  ///
  /// ```
  /// RuntimeDocument document = RuntimeDocument.fromMap(
  ///   "data/document", {"A": "Data is A", "B": "Data is B"}
  /// );
  /// document["A"] // Data is A;
  /// document["C"] = "Data is C";
  /// ```
  ///
  /// [path]: Document path. If empty, a UUID will be assigned.
  /// [mapData]: Map data to be stored.
  factory RuntimeDocument.fromMap(String path, Map<String, dynamic> mapData) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    RuntimeDocument document = PathMap.get<RuntimeDocument>(path);
    if (document != null) {
      if (mapData != null) document.set(_convertData(path, mapData));
      return document;
    }
    return RuntimeDocument._(path: path, children: _convertData(path, mapData));
  }
  RuntimeDocument._(
      {String path, Iterable<DataField> children, bool isTemporary = false})
      : super(path, children: children, isTemporary: isTemporary);

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.data;

  /// Create a new field.
  ///
  /// [path]: Field path.
  /// [value]: Field value.
  @override
  DataField createField([String path, value]) => DataField(path, value);
}
