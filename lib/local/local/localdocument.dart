part of masamune.local;

/// Manage Local documents.
///
/// Basically load, set the value if there is a value to update and [save()].
///
/// ```
/// LocalDocument doc = LocalDocument.load( "user/user" );
/// String name = doc.getString( "name" );
/// doc["age"] = 18;
/// doc.save();
/// ```
class LocalDocument extends Document<DataField>
    with DataDocumentMixin<DataField>
    implements IDataDocument<DataField> {
  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      LocalDocument._(
          path: path,
          isTemporary: isTemporary,
          group: this.group,
          order: this.order) as T;

  /// Manage Local documents.
  ///
  /// Basically load, set the value if there is a value to update and [save()].
  ///
  /// ```
  /// LocalDocument doc = LocalDocument.load( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// Request and listen to a document.
  ///
  /// [path]: Document path.
  factory LocalDocument(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return null;
    }
    LocalDocument document = PathMap.get<LocalDocument>(path);
    if (document != null) return document;
    Log.warning(
        "No data was found from the pathmap. Please execute [load()] first.");
    return null;
  }

  /// Manage Local documents.
  ///
  /// Basically load, set the value if there is a value to update and [save()].
  ///
  /// ```
  /// LocalDocument doc = LocalDocument.load( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// Request and listen to a document.
  ///
  /// [path]: Document path.
  static LocalDocument load(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return null;
    }
    LocalDocument document = PathMap.get<LocalDocument>(path);
    if (document != null) {
      return document.reload();
    }
    document = LocalDocument._(path: path);
    document._loadFromPrefs();
    return document;
  }

  /// Manage Local documents.
  ///
  /// Basically load, set the value if there is a value to update and [save()].
  ///
  /// ```
  /// LocalDocument doc = LocalDocument.load( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// Create a LocalDocument that has not yet been synchronized with the local database.
  ///
  /// [path]: Document path
  /// [data]: Data set locally
  static LocalDocument create(String path, [Map<String, dynamic> data]) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return null;
    }
    LocalDocument document = PathMap.get<LocalDocument>(path);
    if (document != null) {
      if (data != null) document.set(_convertData(path, data));
      return document;
    }
    document = LocalDocument._(path: path, isTemporary: true);
    if (data != null) document.set(_convertData(path, data));
    return document;
  }

  /// Manage Local documents.
  ///
  /// Basically load, set the value if there is a value to update and [save()].
  ///
  /// ```
  /// LocalDocument doc = LocalDocument.load( "user/user" );
  /// String name = doc.getString( "name" );
  /// doc["age"] = 18;
  /// doc.save();
  /// ```
  ///
  /// Delete the document at the specified path.
  ///
  /// [path]: Document path to delete.
  static void deleteAt(String path) async {
    path = path?.replaceAll("https", "firestore")?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 0));
    if (length <= 0 || length % 2 != 0) {
      Log.error("Path is not document path.");
      return;
    }
    LocalDocument document = PathMap.get<LocalDocument>(path);
    if (document == null) document = LocalDocument._(path: path);
    document.delete();
  }

  LocalDocument._(
      {String path,
      Iterable<DataField> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super(path,
            children: children,
            isTemporary: isTemporary,
            group: group,
            order: order);
  static Iterable<DataField> _convertData(
      String path, Map<String, dynamic> data) {
    List<DataField> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      list.add(DataField(Paths.child(path, key), value));
    });
    return list;
  }

  /// Update document data.
  LocalDocument reload() {
    this._loadFromPrefs();
    return this;
  }

  void _loadFromPrefs() {
    try {
      String json = Prefs.getString("local://" + this.path);
      if (isEmpty(json)) return;
      Map<String, dynamic> map = Json.decodeAsMap(json);
      this._setInternal(map);
      this.notifyUpdate();
    } catch (e) {
      Log.error(e.toString());
    }
  }

  void _setInternal(Map<String, dynamic> data) {
    if (data == null) return;
    data.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      this[key] = value;
    });
    List<String> list = List.from(this.data.keys);
    for (String tmp in list) {
      if (!data.containsKey(tmp)) this.remove(tmp);
    }
    list.release();
    Log.ast("Updated data: %s (%s)", [this.path, this.runtimeType]);
  }

  /// Apply the changed document data to the local database.
  @override
  Future<T> save<T extends IDataDocument>() {
    if (this.isDisposed) return Future.delayed(Duration.zero);
    if (this.data == null || this.data.length <= 0) {
      Prefs.remove("local://" + this.path);
    } else {
      String json = Json.encode(this.data.keys);
      if (isEmpty(json)) {
        Prefs.remove("local://" + this.path);
      } else {
        Prefs.set("local://" + this.path, json);
      }
    }
    LocalCollection collection = LocalCollection.load(Paths.parent(this.path));
    if (collection != null) collection._saveInternal(this);
    this.notifyUpdate();
    return this.asFuture();
  }

  /// Delete this FirestoreDocument path from the local database.
  ///
  /// This object itself is also [dispose()].
  @override
  Future delete() {
    if (this.isDisposed) return Future.delayed(Duration.zero);
    Prefs.remove("local://" + this.path);
    LocalCollection collection = LocalCollection.load(Paths.parent(this.path));
    if (collection != null) collection._deleteInternal(this);
    this.dispose();
    return Future.delayed(Duration.zero);
  }

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.local;

  /// Create a new field.
  ///
  /// [path]: Field path.
  /// [value]: Field value.
  @override
  DataField createField([String path, value]) => DataField(path, value);
}
