part of masamune.local;

/// Get the Local collection.
///
/// Gets all the documents stored locally.
///
/// ```
/// LocalCollection col = LocalCollection.listen( "user/user" );
/// for( LocalDoccument doc in col ) { ... }
/// String name = doc.getString( "name" );
/// newDocument["age"] = 18;
/// newDocument.save();
/// ```
class LocalCollection extends Collection<LocalDocument>
    with SortableDataCollectionMixin<LocalDocument>
    implements IDataCollection<LocalDocument> {
  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      LocalCollection._(
          path: path,
          isTemporary: isTemporary,
          group: group,
          order: order,
          orderBy: this.orderBy,
          thenBy: this.thenBy,
          orderByKey: this.orderByKey,
          thenByKey: this.thenByKey) as T;

  /// Get the Local collection.
  ///
  /// Gets all the documents stored locally.
  ///
  /// ```
  /// LocalCollection col = LocalCollection.listen( "user/user" );
  /// for( LocalDoccument doc in col ) { ... }
  /// String name = doc.getString( "name" );
  /// newDocument["age"] = 18;
  /// newDocument.save();
  /// ```
  ///
  /// [path]: Collection path.
  factory LocalCollection(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 1));
    if (length <= 0 || length % 2 != 1) {
      Log.error("Path is not document path.");
      return null;
    }
    LocalCollection collection = PathMap.get<LocalCollection>(path);
    if (collection != null) return collection;
    Log.warning(
        "No data was found from the pathmap. Please execute [load()] first.");
    return null;
  }

  /// Get the Local collection.
  ///
  /// Gets all the documents stored locally.
  ///
  /// ```
  /// LocalCollection col = LocalCollection.listen( "user/user" );
  /// for( LocalDoccument doc in col ) { ... }
  /// String name = doc.getString( "name" );
  /// newDocument["age"] = 18;
  /// newDocument.save();
  /// ```
  ///
  /// [path]: Collection path.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  static LocalCollection load(String path,
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    int length = Paths.length(path);
    assert(!(length <= 0 || length % 2 != 1));
    if (length <= 0 || length % 2 != 1) {
      Log.error("Path is not document path.");
      return null;
    }
    LocalCollection collection = PathMap.get<LocalCollection>(path);
    if (collection != null) {
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      return collection.reload();
    }
    collection = LocalCollection._(
        path: path,
        orderBy: orderBy,
        thenBy: thenBy,
        orderByKey: orderByKey,
        thenByKey: thenByKey);
    collection._loadFromPrefs();
    return collection;
  }

  LocalCollection._(
      {String path,
      Iterable<LocalDocument> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : super(path,
            children: children,
            isTemporary: isTemporary,
            group: group,
            order: order) {
    this.orderBy = orderBy;
    this.thenBy = thenBy;
    this.orderByKey = orderByKey;
    this.thenByKey = thenByKey;
  }

  /// Update document data.
  LocalCollection reload() {
    this._loadFromPrefs();
    return this;
  }

  void _loadFromPrefs() {
    try {
      String json = Prefs.getString("local://" + this.path);
      if (isEmpty(json)) return;
      List<dynamic> data = Json.decodeAsList(json);
      if (data != null) {
        List<LocalDocument> addData = ListPool.get();
        for (dynamic tmp in data) {
          if (!(tmp is String)) continue;
          String key = tmp as String;
          if (isEmpty(key)) continue;
          String path = Paths.child(this.path, key);
          String dicJson = Prefs.getString("local://" + path);
          if (isEmpty(dicJson)) continue;
          Map map = Json.decodeAsMap(dicJson);
          if (this.data.containsKey(key) && this.data[key] is LocalDocument) {
            this.data[key]?._setInternal(map);
          } else {
            addData.add(LocalDocument.create(path, map));
          }
        }
        this._setInternal(addData);
        for (int i = this.data.length - 1; i >= 0; i--) {
          LocalDocument doc = this.data[i];
          if (doc == null) continue;
          if (!data.any((key) => doc.id == (key as String))) this.remove(doc);
        }
        Log.ast("Updated data: %s (%s)", [this.path, this.runtimeType]);
      }
      this.sort();
      this.notifyUpdate();
    } catch (e) {
      Log.error(e.toString());
    }
  }

  void _setInternal(Iterable<LocalDocument> children) {
    if (children != null) {
      for (LocalDocument doc in children) {
        if (doc == null) continue;
        this.setInternal(doc);
      }
    }
  }

  /// Apply the changed collection data to the local database.
  void save() {
    this._isUpdating = true;
    for (LocalDocument tmp in this.data.values) tmp?.save();
    this._isUpdating = false;
    this._saveInternal();
    this.notifyUpdate();
  }

  void _saveInternal([LocalDocument document]) {
    if (this._isUpdating) return;
    if (document != null && !this.data.containsKey(document.id))
      this.data[document.id] = document;
    List<String> keys = List.from(this.data.keys);
    String jsonList = Prefs.getString("local://" + this.path);
    if (isNotEmpty(jsonList)) {
      List<dynamic> data = Json.decodeAsList(jsonList);
      if (data != null) {
        for (dynamic tmp in data) {
          if (!(tmp is String)) continue;
          String key = tmp as String;
          if (isEmpty(key) || keys.contains(key)) continue;
          Prefs.remove("local://" + Paths.child(this.path, key));
        }
      }
    }
    if (keys == null || keys.length <= 0) {
      Prefs.remove("local://" + this.path);
    } else {
      String json = Json.encode(keys);
      if (isEmpty(json)) {
        Prefs.remove("local://" + this.path);
      } else {
        Prefs.set("local://" + this.path, json);
      }
    }
  }

  /// Delete this FirestoreCollection path from the local database.
  ///
  /// This object itself is also [dispose()].
  void delete() {
    if (this.isDisposed) return;
    this._isUpdating = true;
    List<String> keys = List.from(this.data.keys);
    for (String key in keys) {
      if (isEmpty(key)) continue;
      LocalDocument doc = this.data[key];
      if (doc == null) continue;
      doc.delete();
      this.data.remove(key);
    }
    this._isUpdating = false;
    String jsonList = Prefs.getString("local://" + this.path);
    if (isNotEmpty(jsonList)) {
      List<dynamic> data = Json.decodeAsList(jsonList);
      if (data != null) {
        for (dynamic tmp in data) {
          if (!(tmp is String)) continue;
          String key = tmp as String;
          if (isEmpty(key)) continue;
          Prefs.remove("local://" + Paths.child(this.path, key));
        }
      }
    }
    Prefs.remove("local://" + this.path);
    this.dispose();
  }

  void _deleteInternal([LocalDocument document]) {
    if (document == null) return;
    if (this.data.containsKey(document.id)) this.data.remove(document.id);
    this._saveInternal();
  }
  bool _isUpdating = false;

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.local;
}
