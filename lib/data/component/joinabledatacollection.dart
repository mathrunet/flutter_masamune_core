part of masamune.data;

/// Class for adding new data to a data collection.
///
/// The added data is stored in
/// a different path to distinguish it from the original data.
///
/// ```
/// JoinableDataCollection.from("joined/data", firestoreCollection)
/// .request(key:"id", builder: (collection) => DataCollection("source"));
/// ```
class JoinableDataCollection extends TaskCollection<DataDocument>
    with SortableDataCollectionMixin<DataDocument>
    implements IDataCollection<DataDocument> {
  static Iterable<DataDocument> _convertData(
      String path, IDataCollection data) {
    List<DataDocument> list = ListPool.get();
    data?.forEach((value) {
      if (value == null) return;
      list.add(
          value.clone(path: Paths.child(path, value.id), isTemporary: false));
    });
    return list;
  }

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class
  @override
  Completer createCompleter() => Completer<JoinableDataCollection>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      JoinableDataCollection._(path: path, isTemporary: false) as T;

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.data;

  /// Class for adding new data to a data collection.
  ///
  /// The added data is stored in
  /// a different path to distinguish it from the original data.
  ///
  /// ```
  /// JoinableDataCollection.from("joined/data", firestoreCollection)
  /// .request(key:"id", builder: (collection) => DataCollection("source"));
  /// ```
  ///
  /// [path]: The path.
  factory JoinableDataCollection(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    JoinableDataCollection collection =
        PathMap.get<JoinableDataCollection>(path);
    if (collection != null) return collection;
    Log.warning(
        "No data was found from the pathmap. Please execute [listen()] first.");
    return null;
  }

  /// Class for adding new data to a data collection.
  ///
  /// The added data is stored in
  /// a different path to distinguish it from the original data.
  ///
  /// ```
  /// JoinableDataCollection.from("joined/data", firestoreCollection)
  /// .request(key:"id", builder: (collection) => DataCollection("source"));
  /// ```
  ///
  /// Create a JoinableDataCollection from the data source.
  ///
  /// [path]: The path.
  /// [source]: Data source.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  static JoinableDataCollection from(String path, IDataCollection source,
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
    JoinableDataCollection collection =
        PathMap.get<JoinableDataCollection>(path);
    if (collection != null) {
      if (source != null) {
        if (source != collection && source.path != collection.path) {
          collection._setInternal(_convertData(path, source));
        }
      }
      return collection;
    }
    collection = JoinableDataCollection._(
        path: path, children: _convertData(path, source));
    return collection;
  }

  void _setInternal(Iterable<DataDocument> children) {
    this.data.clear();
    if (children != null) {
      for (DataDocument doc in children) {
        if (doc == null) continue;
        this.setInternal(doc);
      }
    }
  }

  JoinableDataCollection._(
      {String path,
      Iterable<DataDocument> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : super(
            path: path,
            children: children,
            isTemporary: isTemporary,
            group: group,
            order: order) {
    this.orderBy = orderBy;
    this.thenBy = thenBy;
    this.orderByKey = orderByKey;
    this.thenByKey = thenByKey;
  }

  /// Add data to the original data.
  ///
  /// Specify either [key] or [test].
  ///
  /// [key]: The key of the data to compare.
  /// If the data of this key matches, that data is added to the original data.
  /// [test]: Callback for comparison.
  /// If True is returned, the data will be added to the original data.
  /// [builder]: Callback to get the data.
  Future<JoinableDataCollection> joinFrom(
      {String key,
      bool test(IDataDocument newDocument, IDataDocument oldDocument),
      @required
          Future<IDataCollection> builder(IDataCollection collection)}) async {
    assert(isNotEmpty(key) && test == null);
    assert(isEmpty(key) && test != null);
    assert(builder != null);
    if (builder == null) return this;
    if (isEmpty(key) && test == null) return this;
    if (isNotEmpty(key) && test != null) return this;
    IDataCollection collection = await builder(this);
    if (isNotEmpty(key)) {
      for (MapEntry<String, DataDocument> tmp in this.data.entries) {
        if (tmp.value == null || !tmp.value.containsKey(key)) continue;
        IDataDocument doc = collection.firstWhere((element) =>
            element.containsKey(key) && tmp.value[key] == element[key]);
        if (doc != null) continue;
        for (MapEntry<String, IDataField> data in doc.entries) {
          if (isEmpty(data.key) || data.value == null) continue;
          tmp.value[data.key] = data.value;
        }
      }
    } else if (test != null) {
      for (MapEntry<String, DataDocument> tmp in this.data.entries) {
        if (tmp.value == null) continue;
        IDataDocument doc =
            collection.firstWhere((element) => test(tmp.value, element));
        if (doc != null) continue;
        for (MapEntry<String, IDataField> data in doc.entries) {
          if (isEmpty(data.key) || data.value == null) continue;
          tmp.value[data.key] = data.value;
        }
      }
    }
    return this;
  }
}

/// Class that extends IDataCollection.
extension JoinableDataCollectionExtension<T extends IDataCollection> on T {
  /// Add data to the original data.
  ///
  /// Specify either [key] or [test].
  ///
  /// [path]: Path of JoinableDataCollection.
  /// [key]: The key of the data to compare.
  /// If the data of this key matches, that data is added to the original data.
  /// [test]: Callback for comparison.
  /// If True is returned, the data will be added to the original data.
  /// [builder]: Callback to get the data.
  Future<JoinableDataCollection> joinFrom(String path,
      {String key,
      bool test(IDataDocument newField, IDataDocument oldField),
      @required Future<IDataCollection> builder(IDataCollection collection)}) {
    IDataCollection collection = PathMap.get<IDataCollection>(path);
    if (collection is JoinableDataCollection) {
      return collection.joinFrom(key: key, test: test, builder: builder);
    } else {
      return JoinableDataCollection.from(path, this)
          ?.joinFrom(key: key, test: test, builder: builder);
    }
  }
}
