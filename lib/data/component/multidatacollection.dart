part of masamune.data;

/// It is a class that can store multiple collections and handle them as one collection.
///
/// By using the [fromFuture] method, tasks waiting in Future can be together.
///
/// ```
/// MultiDDataCollection collections = MultiDataCollection(
///   collections: [
///     DataCollection(),
///     DataCollection()
///   ]
/// );
/// ```
///
///
/// [MultiDataCollection]
/// Use multiple collections as one collection.
///
/// [JoinableDataCollection]
/// You can merge the two collections
/// by requesting a new collection based on the source collection,
/// much like an SQL outer join.
///
/// [UnitaryDataCollection]
/// Use multiple collections as one collection.
/// Documents with equal terms can be combined into a single document.
/// Use this when you want to view and save multiple documents as a single document.
///
/// [SearchableMultiDataCollection]
/// Collections that can combine multiple collections
/// into a single collection that can be further filtered by search.
class MultiDataCollection extends Collection<IDataDocument>
    with SortableDataCollectionMixin<IDataDocument>
    implements IDataCollection<IDataDocument> {
  List<IDataCollection> _collection;

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      MultiDataCollection._(
          path: path,
          collections: this._collection,
          isTemporary: isTemporary) as T;

  /// Get the protocol of the path
  @override
  String get protocol => Protocol.data;

  /// It is a class that can store multiple collections and handle them as one collection.
  ///
  /// By using the [fromFuture] method, tasks waiting in Future can be together.
  ///
  /// ```
  /// MultiDDataCollection collections = MultiDataCollection(
  ///   collections: [
  ///     DataCollection(),
  ///     DataCollection()
  ///   ]
  /// );
  /// ```
  ///
  /// [path]: Collection path.
  /// [collections]: The collection to store.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory MultiDataCollection(String path,
      {Iterable<IDataCollection> collections = const [],
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    MultiDataCollection collection = PathMap.get<MultiDataCollection>(path);
    if (collection != null) {
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      if (collections != null) {
        collection._collection = collections;
        collection._build();
      }
      return collection;
    }
    return MultiDataCollection._(
        path: path,
        collections: collections,
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }

  /// It is a class that can store multiple collections and handle them as one collection.
  ///
  /// By using the [fromFuture] method, tasks waiting in Future can be together.
  ///
  /// ```
  /// MultiDDataCollection collections = MultiDataCollection(
  ///   collections: [
  ///     DataCollection(),
  ///     DataCollection()
  ///   ]
  /// );
  /// ```
  ///
  /// [path]: Collection path.
  /// [collections]: The collection to store.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  static Future<MultiDataCollection> fromFuture(String path,
      {Iterable<Future<IDataCollection>> collections = const [],
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) async {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    MultiDataCollection collection = PathMap.get<MultiDataCollection>(path);
    if (collection != null) {
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      if (collections != null) {
        collection._collection = await collections?.mapAsync()?.toList();
        collection._build();
      }
      return collection;
    }
    List<IDataCollection> tmp = await collections?.mapAsync()?.toList();
    return MultiDataCollection._(
        path: path,
        collections: tmp,
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }

  MultiDataCollection._(
      {String path,
      Iterable<IDataCollection> collections = const [],
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey,
      bool isTemporary})
      : super(path, isTemporary: (isTemporary ?? false) || isEmpty(path)) {
    this.orderBy = orderBy;
    this.orderByKey = orderByKey;
    this.thenBy = thenBy;
    this.thenByKey = thenByKey;
    this._collection = collections.toList();
    this._collection?.forEach((col) => col?.listen(this._listenInternal));
    this._build();
  }
  void _build() {
    if (this._collection == null || this._collection.length <= 0) return;
    this.clear();
    for (IDataCollection collection in this._collection) {
      if (collection == null) continue;
      for (IDataDocument document in collection) {
        if (document == null) continue;
        this.setInternal(document);
      }
    }
    this.sort();
  }

  void _listenInternal(IDataCollection collection) {
    this._build();
    this.notifyUpdate();
  }

  /// Processing to set a value.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: Value to set.
  @override
  @protected
  void setInternal(IDataDocument value) {
    if (value == null) return;
    String key = value.id;
    if (isEmpty(key)) key = Texts.uuid;
    if (this.data.containsKey(key)) return;
    IDataDocument exist = this.data.firstWhere(
        (k, v) => v.path == value.path || v == value,
        orElse: () => null);
    if (exist != null) return;
    this.data[key] = value;
    if (!this.isTemporary && isNotEmpty(this.path)) {
      this.data[key].linkTo(Paths.child(this.path, key));
    }
    this.notifyUpdate(value.updatedTime);
  }

  /// Processing to delete values.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: The value to remove.
  @protected
  void unsetInternal(IDataDocument child) {
    if (!this.data.containsValue(child)) return;
    this.data.remove(child.id);
    if (!this.isTemporary && isNotEmpty(this.path)) {
      PathMap.removePath(Paths.child(this.path, child.id));
    }
    this.notifyUpdate();
  }

  /// Register the temporary data in the path map.
  ///
  /// Not registered if the protocol is temporary.
  @override
  @protected
  void registerUntemporary() {
    super.registerUntemporary();
    this.forEach((doc) => doc.linkTo(Paths.child(this.path, doc.id)));
  }

  /// Get the data.
  ///
  /// [key]: Key for retrieving data.
  DataDocument operator [](Object key) {
    if (key is int) {
      if (key < 0 || this.data.length <= key) return null;
      return this.data[key];
    } else if (key is String) {
      if (isEmpty(key) || !this.data.containsKey(key)) return null;
      return this.data[key];
    }
    return null;
  }

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  void dispose() {
    if (this.isDisposed || !this.isDisposable) return;
    this._collection?.forEach((col) => col.unlisten(this._listenInternal));
    super.dispose();
  }
}
