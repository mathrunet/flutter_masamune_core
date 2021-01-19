part of masamune.data;

/// Collection class for storing data.
///
/// Can store DataDocument.
///
/// Since it has the same structure as FireStore, it can be used without discomfort.
///
/// [Iterable<DataDocument>] is available in the for statement because it is MixIn.
///
/// ```
/// DataCollection collection = DataCollection();
/// collection.add(
///   DataDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
/// );
/// for( DataDocument document in colletion ){ ... }
/// ```
class DataCollection extends Collection<DataDocument>
    with SortableDataCollectionMixin<DataDocument>
    implements IDataCollection<DataDocument> {
  static Iterable<DataDocument> _convertDataFromMap(
      String path, Map<String, dynamic> data) {
    List<DataDocument> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      if (!(value is Map)) return;
      list.add(DataDocument.fromMap(Paths.child(path, key), (value as Map)));
    });
    return list;
  }

  static Iterable<DataDocument> _convertDataFromList(
      String path, Iterable<dynamic> data) {
    List<DataDocument> list = ListPool.get();
    data?.forEachIndex((value, i) {
      if (value == null || !(value is Map)) return;
      list.add(DataDocument.fromMap(
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
  /// DataCollection collection = DataCollection();
  /// collection.add(
  ///   DataDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( DataDocument document in colletion ){ ... }
  /// ```
  ///
  /// [path]: Collection path.
  factory DataCollection(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    DataCollection collection = PathMap.get<DataCollection>(path);
    if (collection != null) return collection;
    return DataCollection._(path: path);
  }

  /// Collection class for storing data.
  ///
  /// Can store DataDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<DataDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// DataCollection collection = DataCollection();
  /// collection.add(
  ///   DataDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( DataDocument document in colletion ){ ... }
  /// ```
  ///
  /// [path]: Collection path.
  /// [jsonData]: Json string representing Map.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory DataCollection.fromJson(String path, String jsonData,
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    dynamic data = Json.decode(jsonData);
    switch (data?.runtimeType) {
      case List:
        return DataCollection.fromList(path, data as List,
            orderBy: orderBy,
            orderByKey: orderByKey,
            thenBy: thenBy,
            thenByKey: thenByKey);
      case Map:
        return DataCollection.fromMap(path, data as Map,
            orderBy: orderBy,
            orderByKey: orderByKey,
            thenBy: thenBy,
            thenByKey: thenByKey);
      default:
        return DataCollection(path);
    }
  }

  /// Collection class for storing data.
  ///
  /// Can store DataDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<DataDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// DataCollection collection = DataCollection();
  /// collection.add(
  ///   DataDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( DataDocument document in colletion ){ ... }
  /// ```
  ///
  /// [path]: Collection path.
  /// [mapData]: Map data to be stored.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory DataCollection.fromMap(String path, Map<String, dynamic> mapData,
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
    DataCollection collection = PathMap.get<DataCollection>(path);
    if (collection != null) {
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      if (mapData != null) {
        collection.clear();
        collection.set(_convertDataFromMap(path, mapData));
      }
      return collection;
    }
    return DataCollection._(
        path: path,
        children: _convertDataFromMap(path, mapData),
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }

  /// Collection class for storing data.
  ///
  /// Can store DataDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<DataDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// DataCollection collection = DataCollection();
  /// collection.add(
  ///   DataDocument.fromMap( "data/document", {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( DataDocument document in colletion ){ ... }
  /// ```
  ///
  /// [path]: Collection path.
  /// [listData]: List data to be stored.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory DataCollection.fromList(String path, Iterable<dynamic> listData,
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
    DataCollection collection = PathMap.get<DataCollection>(path);
    if (collection != null) {
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      if (listData != null) {
        collection.clear();
        collection.set(_convertDataFromList(path, listData));
      }
      return collection;
    }
    return DataCollection._(
        path: path,
        children: _convertDataFromList(path, listData),
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }
  DataCollection._(
      {String path,
      Iterable<DataDocument> children,
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
}
