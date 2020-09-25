part of masamune.data;

/// Collection class for storing data.
///
/// Can store RuntimeDocument.
///
/// Since it has the same structure as FireStore, it can be used without discomfort.
///
/// [Iterable<RuntimeDocument>] is available in the for statement because it is MixIn.
///
/// ```
/// RuntimeCollection collection = RuntimeCollection();
/// collection.add(
///   RuntimeDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
/// );
/// for( RuntimeDocument document in colletion ){ ... }
/// ```
class RuntimeCollection extends Collection<RuntimeDocument>
    with SortableDataCollectionMixin<RuntimeDocument>
    implements IDataCollection<RuntimeDocument> {
  static Iterable<RuntimeDocument> _convertDataFromMap(
      String path, Map<String, dynamic> data) {
    List<RuntimeDocument> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      if (!(value is Map)) return;
      list.add(RuntimeDocument.fromMap(Paths.child(path, key), (value as Map)));
    });
    return list;
  }

  static Iterable<RuntimeDocument> _convertDataFromList(
      String path, Iterable<dynamic> data) {
    List<RuntimeDocument> list = ListPool.get();
    data?.forEachIndex((value, i) {
      if (value == null || !(value is Map)) return;
      list.add(RuntimeDocument.fromMap(
          Paths.child(path, i.toString()), (value as Map)));
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
      DataCollection._(
          path: path,
          isTemporary: isTemporary,
          orderBy: this.orderBy,
          orderByKey: this.orderByKey,
          thenBy: this.thenBy,
          thenByKey: this.thenByKey) as T;

  /// Collection class for storing data.
  ///
  /// Can store DataDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<DataDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// RuntimeCollection collection = RuntimeCollection();
  /// collection.add(
  ///   RuntimeDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( RuntimeDocument document in colletion ){ ... }
  /// ```
  ///
  /// [path]: Collection path.
  factory RuntimeCollection(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    RuntimeCollection collection = PathMap.get<RuntimeCollection>(path);
    if (collection != null) return collection;
    return RuntimeCollection._(path: path);
  }

  /// Collection class for storing data.
  ///
  /// Can store RuntimeDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<RuntimeDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// RuntimeCollection collection = RuntimeCollection();
  /// collection.add(
  ///   RuntimeDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( RuntimeDocument document in colletion ){ ... }
  /// ```
  ///
  /// [path]: Collection path.
  /// [jsonData]: Json string representing Map.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory RuntimeCollection.fromJson(String path, String jsonData,
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    dynamic data = Json.decode(jsonData);
    switch (data?.runtimeType) {
      case List:
        return RuntimeCollection.fromList(path, data as List,
            orderBy: orderBy,
            orderByKey: orderByKey,
            thenBy: thenBy,
            thenByKey: thenByKey);
      case Map:
        return RuntimeCollection.fromMap(path, data as Map,
            orderBy: orderBy,
            orderByKey: orderByKey,
            thenBy: thenBy,
            thenByKey: thenByKey);
      default:
        return RuntimeCollection(path);
    }
  }

  /// Collection class for storing data.
  ///
  /// Can store RuntimeDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<RuntimeDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// RuntimeCollection collection = RuntimeCollection();
  /// collection.add(
  ///   RuntimeDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( RuntimeDocument document in colletion ){ ... }
  /// ```
  ///
  /// [path]: Collection path.
  /// [mapData]: Map data to be stored.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory RuntimeCollection.fromMap(String path, Map<String, dynamic> mapData,
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    RuntimeCollection collection = PathMap.get<RuntimeCollection>(path);
    if (collection != null) {
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      if (mapData != null) collection.set(_convertDataFromMap(path, mapData));
      return collection;
    }
    return RuntimeCollection._(
        path: path,
        children: _convertDataFromMap(path, mapData),
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }

  /// Collection class for storing data.
  ///
  /// Can store RuntimeDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<RuntimeDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// RuntimeCollection collection = RuntimeCollection();
  /// collection.add(
  ///   RuntimeDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( RuntimeDocument document in colletion ){ ... }
  /// ```
  ///
  /// [path]: Collection path.
  /// [listData]: List data to be stored.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory RuntimeCollection.fromList(String path, Iterable<dynamic> listData,
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    RuntimeCollection collection = PathMap.get<RuntimeCollection>(path);
    if (collection != null) {
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      if (listData != null)
        collection.set(_convertDataFromList(path, listData));
      return collection;
    }
    return RuntimeCollection._(
        path: path,
        children: _convertDataFromList(path, listData),
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }
  RuntimeCollection._(
      {String path,
      Iterable<RuntimeDocument> children,
      bool isTemporary = false,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : super(path,
            children: children, isTemporary: isEmpty(path) || isTemporary) {
    this.orderBy = orderBy;
    this.orderByKey = orderByKey;
    this.thenBy = thenBy;
    this.thenByKey = thenByKey;
    if (this.length > 0) this.sort();
  }

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.data;

  /// Get the data.
  ///
  /// [key]: Key for retrieving data.
  RuntimeDocument operator [](Object key) {
    if (key is int) {
      if (key < 0 || this.data.length <= key) return null;
      return this.data[key];
    } else if (key is String) {
      if (isEmpty(key) || !this.data.containsKey(key)) return null;
      return this.data[key];
    }
    return null;
  }
}
