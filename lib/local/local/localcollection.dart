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
    LocalCollection collection = PathMap.get<LocalCollection>(path);
    if (collection != null) {
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      collection.reload();
      return collection;
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
  Future<T> reload<T extends IDataCollection>() async {
    this._loadFromPrefs();
    return this as T;
  }

  void _loadFromPrefs() {
    try {
      Map<String, dynamic> data = LocalDocument._root.readFromPath(this.path);
      this.data.clear();
      if (data != null) {
        List<LocalDocument> addData = ListPool.get();
        for (MapEntry<String, dynamic> tmp in data.entries) {
          if (isEmpty(tmp.key) || !(tmp.value is Map<String, dynamic>))
            continue;
          if (this.data.containsKey(tmp.key) &&
              this.data[tmp.key] is LocalDocument) {
            this.data[tmp.key]?._setInternal(tmp.value);
          } else {
            addData.add(LocalDocument.create(
                Paths.child(this.path, tmp.key), tmp.value));
          }
        }
        this._setInternal(addData);
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
    for (LocalDocument tmp in this.data.values) tmp?.save();
  }

  /// Delete this FirestoreCollection path from the local database.
  ///
  /// This object itself is also [dispose()].
  void delete() {
    if (this.isDisposed) return;
    for (int i = this.data.length - 1; i >= 0; i--) {
      LocalDocument doc = this.data[i];
      if (doc == null) continue;
      doc.delete();
    }
    this.clear();
  }

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.local;
}
