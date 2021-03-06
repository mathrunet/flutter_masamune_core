part of masamune.data;

/// Collection class for storing temporary data.
///
/// Can store TempDocument.
///
/// Since it has the same structure as FireStore, it can be used without discomfort.
///
/// [Iterable<TempDocument>] is available in the for statement because it is MixIn.
///
/// ```
/// TempCollection collection = TempCollection();
/// collection.add(
///   TempDocument.fromMap( {"A": "Data is A", "B": "Data is B"} )
/// );
/// for( TempDocument document in colletion ){ ... }
/// ```
class TempCollection extends Collection<TempDocument>
    with SortableDataCollectionMixin<TempDocument>
    implements IDataCollection<TempDocument> {
  static Iterable<TempDocument> _convertDataFromMap(Map<String, dynamic> data) {
    List<TempDocument> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      if (!(value is Map)) return;
      list.add(TempDocument._fromMapWithKey(key, value as Map));
    });
    return list;
  }

  static Iterable<TempDocument> _convertDataFromList(Iterable<dynamic> data) {
    List<TempDocument> list = ListPool.get();
    data?.forEachIndex((value, i) {
      if (value == null || !(value is Map)) return;
      list.add(TempDocument.fromMap(value as Map));
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
      TempCollection._(
          orderBy: this.orderBy,
          orderByKey: this.orderByKey,
          thenBy: this.thenBy,
          thenByKey: this.thenByKey) as T;

  /// Collection class for storing temporary data.
  ///
  /// Can store TemporaryDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<TempDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// TempCollection collection = TempCollection();
  /// collection.add(
  ///   TempDocument.fromMap( {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( TempDocument document in colletion ){ ... }
  /// ```
  factory TempCollection(
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    return TempCollection._(
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }

  /// Collection class for storing temporary data.
  ///
  /// Can store TempDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<TempDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// TempCollection collection = TempCollection();
  /// collection.add(
  ///   TempDocument.fromMap( {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( TempDocument document in colletion ){ ... }
  /// ```
  ///
  /// [jsonData]: Json string representing Map.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory TempCollection.fromJson(String jsonData,
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    dynamic data = Json.decode(jsonData);
    switch (data?.runtimeType) {
      case List:
        return TempCollection.fromList(data as List,
            orderBy: orderBy,
            orderByKey: orderByKey,
            thenBy: thenBy,
            thenByKey: thenByKey);
      case Map:
        return TempCollection.fromMap(data as Map,
            orderBy: orderBy,
            orderByKey: orderByKey,
            thenBy: thenBy,
            thenByKey: thenByKey);
      default:
        return TempCollection(
            orderBy: orderBy,
            orderByKey: orderByKey,
            thenBy: thenBy,
            thenByKey: thenByKey);
    }
  }

  /// Collection class for storing temporary data.
  ///
  /// Can store TempDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<TempDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// TempCollection collection = TempCollection();
  /// collection.add(
  ///   TempDocument.fromMap( {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( TempDocument document in colletion ){ ... }
  /// ```
  ///
  /// [mapData]: Map data to be stored.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory TempCollection.fromMap(Map<String, dynamic> mapData,
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    return TempCollection._(
        children: _convertDataFromMap(mapData),
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }

  /// Collection class for storing temporary data.
  ///
  /// Can store TempDocument.
  ///
  /// Since it has the same structure as FireStore, it can be used without discomfort.
  ///
  /// [Iterable<TempDocument>] is available in the for statement because it is MixIn.
  ///
  /// ```
  /// TempCollection collection = TempCollection();
  /// collection.add(
  ///   TempDocument.fromMap( {"A": "Data is A", "B": "Data is B"} )
  /// );
  /// for( TempDocument document in colletion ){ ... }
  /// ```
  ///
  /// [listData]: List data to be stored.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory TempCollection.fromList(Iterable<dynamic> listData,
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    return TempCollection._(
        children: _convertDataFromList(listData),
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }
  TempCollection._(
      {Iterable<TempDocument> children,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : super(null, children: children, isTemporary: true) {
    this.orderBy = orderBy;
    this.orderByKey = orderByKey;
    this.thenBy = thenBy;
    this.thenByKey = thenByKey;
    if (this.length > 0) this.sort();
  }

  /// Processing to set a value.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: Value to set.
  @protected
  void setInternal(TempDocument value) {
    if (value == null) return;
    String key = value.id;
    if (isEmpty(key)) key = Texts.uuid;
    TempDocument exist =
        this.data.firstWhere((k, v) => v == value, orElse: () => null);
    if (exist != null) {
      if (exist != value) value.copyTo(exist);
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
  void unsetInternal(TempDocument child) {
    if (child == null) return;
    if (!this.data.containsKey(child.id)) return;
    child?.dispose();
    this.data.remove(child.id);
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

  /// Get the data.
  ///
  /// [key]: Key for retrieving data.
  TempDocument operator [](Object key) {
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
