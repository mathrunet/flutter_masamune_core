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
      DataDocument doc = DataDocument(Paths.child(path, value.id));
      for (MapEntry<String, IDataField> tmp in value.entries) {
        doc[tmp.key] = tmp.value;
      }
      list.add(doc);
    });
    return list;
  }

  IDataCollection _source;
  List<_JoinEntry> _listener = ListPool.get();

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
          collection._setInternal(
              source: source, children: _convertData(path, source));
        }
      }
      return collection;
    }
    collection = JoinableDataCollection._(
        path: path, source: source, children: _convertData(path, source));
    return collection;
  }

  void _listenUpdate(IPath collection) {
    if (this._source != null) {
      this._source.forEach((value) {
        if (this.data.containsKey(value.id)) {
          IDataDocument doc = this.data[value.id];
          value.forEach((key, val) => doc[key] = val);
        } else {
          IDataDocument doc = DataDocument(Paths.child(this.path, value.id));
          value.forEach((key, val) => doc[key] = val);
        }
      });
      this
          .data
          .removeWhere((key, value) => !this._source.data.keys.contains(key));
      this._setInternal(
          source: this._source,
          children: _convertData(this.path, this._source));
    }
    for (_JoinEntry entry in this._listener) {
      if (entry == null) continue;
      if (entry is _JoinDocumentEntry) {
        if (entry.document == null || entry.document.isDisposed) continue;
        this._applyDocumentInternal(
            key: entry.key,
            test: entry.test,
            prefix: entry.prefix,
            document: entry.document,
            onFound: entry.onFound);
      } else if (entry is _JoinCollectionEntry) {
        if (entry.collection == null || entry.collection.isDisposed) continue;
        this._applyCollectionInternal(
            key: entry.key,
            test: entry.test,
            prefix: entry.prefix,
            collection: entry.collection,
            onFound: entry.onFound,
            onNotFound: entry.onNotFound);
      }
    }
    this.notifyUpdate();
  }

  void _setInternal({IDataCollection source, Iterable<DataDocument> children}) {
    this.data.clear();
    if (this._source != source) {
      if (this._source != null) this._source.unlisten(this._listenUpdate);
      this._source = source;
      if (this._source != null) this._source.listen(this._listenUpdate);
    }
    if (children != null) {
      for (DataDocument doc in children) {
        if (doc == null) continue;
        this.setInternal(doc);
      }
    }
  }

  JoinableDataCollection._(
      {String path,
      IDataCollection source,
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
    this._source = source;
    this.orderBy = orderBy;
    this.thenBy = thenBy;
    this.orderByKey = orderByKey;
    this.thenByKey = thenByKey;
    if (this._source != null) this._source.listen(this._listenUpdate);
  }

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  ///
  /// Copied from Collection.
  @override
  void dispose() {
    if (this.isDisposed || !this.isDisposable) return;
    if (this._source != null) this._source.unlisten(this._listenUpdate);
    this._listener?.forEach((element) {
      if (element is _JoinDocumentEntry) {
        element?.document?.unlisten(this._listenUpdate);
      } else if (element is _JoinCollectionEntry) {
        element?.collection?.unlisten(this._listenUpdate);
      }
    });
    this._listener?.release();
    super.dispose();
  }

  /// Add data to the original data.
  ///
  /// [key]: The key of the data to compare.
  /// If the data of this key matches, that data is added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinAt(
      {@required String key,
      @required Future<IDataCollection> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          String key, DataDocument value, IDataCollection collection),
      String prefix}) async {
    assert(isNotEmpty(key));
    assert(builder != null);
    if (builder == null) return this;
    if (isEmpty(key)) return this;
    this.init();
    IDataCollection collection = await builder(this);
    if (collection == null) return this;
    assert(collection != this && collection.path != this.path);
    if (collection == this || collection.path == this.path) {
      this.error("Cannot specify yourself for a joined collection.");
      return this;
    }
    if (!this._listener.any((entry) =>
        entry is _JoinCollectionEntry &&
        (entry.collection == collection ||
            entry.collection.path == collection.path))) {
      collection.listen(this._listenUpdate);
      this._listener.add(_JoinCollectionEntry(
          key: key,
          prefix: prefix,
          collection: collection,
          onFound: onFound,
          onNotFound: onNotFound));
    }
    this._applyCollectionInternal(
        key: key,
        prefix: prefix,
        collection: collection,
        onFound: onFound,
        onNotFound: onNotFound);
    this.done();
    return this;
  }

  /// Add data to the original data.
  ///
  /// [test]: Callback for comparison.
  /// If True is returned, the data will be added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinWhere(
      {@required bool test(IDataDocument original, IDataDocument additional),
      @required Future<IDataCollection> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          String key, DataDocument value, IDataCollection collection),
      String prefix}) async {
    assert(test != null);
    assert(builder != null);
    if (builder == null) return this;
    if (test == null) return this;
    this.init();
    IDataCollection collection = await builder(this);
    if (collection == null) return this;
    assert(collection != this && collection.path != this.path);
    if (collection == this || collection.path == this.path) {
      this.error("Cannot specify yourself for a joined collection.");
      return this;
    }
    if (!this._listener.any((entry) =>
        entry is _JoinCollectionEntry &&
        (entry.collection == collection ||
            entry.collection.path == collection.path))) {
      collection.listen(this._listenUpdate);
      this._listener.add(_JoinCollectionEntry(
          test: test,
          prefix: prefix,
          collection: collection,
          onFound: onFound,
          onNotFound: onNotFound));
    }
    this._applyCollectionInternal(
        test: test,
        prefix: prefix,
        collection: collection,
        onFound: onFound,
        onNotFound: onNotFound);
    this.done();
    return this;
  }

  /// Add data to the original data.
  ///
  /// [key]: The key of the data to compare.
  /// If the data of this key matches, that data is added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinDocumentAt(
      {@required String key,
      @required Future<IDataDocument> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document),
      void onNotFound(String key, DataDocument value),
      String prefix}) async {
    assert(isNotEmpty(key));
    assert(builder != null);
    if (builder == null) return this;
    if (isEmpty(key)) return this;
    this.init();
    IDataDocument document = await builder(this);
    if (document == null) return this;
    if (!this._listener.any((entry) =>
        entry is _JoinDocumentEntry &&
        (entry.document == document || entry.document.path == document.path))) {
      document.listen(this._listenUpdate);
      this._listener.add(_JoinDocumentEntry(
          key: key,
          prefix: prefix,
          document: document,
          onFound: onFound,
          onNotFound: onNotFound));
    }
    this._applyDocumentInternal(
        key: key,
        prefix: prefix,
        document: document,
        onFound: onFound,
        onNotFound: onNotFound);
    this.done();
    return this;
  }

  /// Add data to the original data.
  ///
  /// [test]: Callback for comparison.
  /// If True is returned, the data will be added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinDocumentWhere(
      {bool test(IDataDocument original, IDataDocument additional),
      @required Future<IDataDocument> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document),
      void onNotFound(String key, DataDocument value),
      String prefix}) async {
    assert(test != null);
    assert(builder != null);
    if (builder == null) return this;
    if (test == null) return this;
    this.init();
    IDataDocument document = await builder(this);
    if (document == null) return this;
    if (!this._listener.any((entry) =>
        entry is _JoinDocumentEntry &&
        (entry.document == document || entry.document.path == document.path))) {
      document.listen(this._listenUpdate);
      this._listener.add(_JoinDocumentEntry(
          test: test,
          prefix: prefix,
          document: document,
          onFound: onFound,
          onNotFound: onNotFound));
    }
    this._applyDocumentInternal(
        test: test,
        prefix: prefix,
        document: document,
        onFound: onFound,
        onNotFound: onNotFound);
    this.done();
    return this;
  }

  void _applyCollectionInternal(
      {String key,
      String prefix,
      bool test(IDataDocument original, IDataDocument additional),
      void onFound(String key, DataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          String key, DataDocument value, IDataCollection collection),
      IDataCollection collection}) {
    if (isNotEmpty(key)) {
      for (MapEntry<String, DataDocument> tmp in this.data.entries) {
        if (tmp.value == null || !tmp.value.containsKey(key)) continue;
        IDataDocument doc = collection.firstWhere(
            (element) =>
                element.containsKey(key) && tmp.value[key] == element[key],
            orElse: () => null);
        if (doc == null) {
          if (onNotFound != null) onNotFound(tmp.key, tmp.value, collection);
          continue;
        }
        if (onFound != null) {
          onFound(tmp.key, tmp.value, doc, collection);
        } else {
          for (MapEntry<String, IDataField> data in doc.entries) {
            if (isEmpty(data.key) || data.value == null) continue;
            String key = data.key;
            if (isNotEmpty(prefix)) key = prefix + key;
            tmp.value[key] = data.value.data;
          }
        }
      }
    } else if (test != null) {
      for (MapEntry<String, DataDocument> tmp in this.data.entries) {
        if (tmp.value == null) continue;
        IDataDocument doc = collection.firstWhere(
            (element) => test(tmp.value, element),
            orElse: () => null);
        if (doc == null) {
          if (onNotFound != null) onNotFound(tmp.key, tmp.value, collection);
          continue;
        }
        if (onFound != null) {
          onFound(tmp.key, tmp.value, doc, collection);
        } else {
          for (MapEntry<String, IDataField> data in doc.entries) {
            if (isEmpty(data.key) || data.value == null) continue;
            String key = data.key;
            if (isNotEmpty(prefix)) key = prefix + key;
            tmp.value[key] = data.value.data;
          }
        }
      }
    }
  }

  void _applyDocumentInternal(
      {String key,
      String prefix,
      bool test(IDataDocument original, IDataDocument additional),
      void onFound(String key, DataDocument value, IDataDocument document),
      void onNotFound(String key, DataDocument value),
      IDataDocument document}) {
    if (isNotEmpty(key)) {
      for (MapEntry<String, DataDocument> tmp in this.data.entries) {
        if (tmp.value == null || !tmp.value.containsKey(key)) continue;
        if (!document.containsKey(key) || tmp.value[key] != document[key]) {
          if (onNotFound != null) onNotFound(tmp.key, tmp.value);
          continue;
        }
        if (onFound != null) {
          onFound(tmp.key, tmp.value, document);
        } else {
          for (MapEntry<String, IDataField> data in document.entries) {
            if (isEmpty(data.key) || data.value == null) continue;
            String key = data.key;
            if (isNotEmpty(prefix)) key = prefix + key;
            tmp.value[key] = data.value.data;
          }
        }
      }
    } else if (test != null) {
      for (MapEntry<String, DataDocument> tmp in this.data.entries) {
        if (tmp.value == null) continue;
        if (!test(tmp.value, document)) {
          if (onNotFound != null) onNotFound(tmp.key, tmp.value);
          continue;
        }
        if (onFound != null) {
          onFound(tmp.key, tmp.value, document);
        } else {
          for (MapEntry<String, IDataField> data in document.entries) {
            if (isEmpty(data.key) || data.value == null) continue;
            String key = data.key;
            if (isNotEmpty(prefix)) key = prefix + key;
            tmp.value[key] = data.value.data;
          }
        }
      }
    }
  }
}

abstract class _JoinEntry {
  final String key;
  final String prefix;
  final bool Function(IDataDocument newDocument, IDataDocument oldDocument)
      test;
  const _JoinEntry({this.key, this.prefix, this.test});
}

class _JoinDocumentEntry extends _JoinEntry {
  final void Function(String key, DataDocument value, IDataDocument document)
      onFound;
  final void Function(String key, DataDocument value) onNotFound;
  final IDataDocument document;
  const _JoinDocumentEntry(
      {String key,
      String prefix,
      bool test(IDataDocument original, IDataDocument additional),
      this.document,
      this.onFound,
      this.onNotFound})
      : super(key: key, prefix: prefix, test: test);
}

class _JoinCollectionEntry extends _JoinEntry {
  final void Function(String key, DataDocument value, IDataDocument document,
      IDataCollection collection) onFound;
  final void Function(
      String key, DataDocument value, IDataCollection collection) onNotFound;
  final IDataCollection collection;
  const _JoinCollectionEntry(
      {String key,
      String prefix,
      bool test(IDataDocument original, IDataDocument additional),
      this.collection,
      this.onFound,
      this.onNotFound})
      : super(key: key, prefix: prefix, test: test);
}

/// Class that extends IDataCollection.
extension JoinableDataCollectionExtension<T extends IDataCollection> on T {
  /// Add data to the original data.
  ///
  /// [path]: Path of JoinableDataCollection.
  /// If not specified, if the object being executed is a JoinaableDataCollection,
  /// the path is as it is, otherwise, joined is added to the beginning of the path.
  /// [key]: The key of the data to compare.
  /// If the data of this key matches, that data is added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinAt(
      {String path,
      String prefix,
      @required String key,
      @required Future<IDataCollection> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          String key, DataDocument value, IDataCollection collection)}) {
    if (isEmpty(path)) {
      if (this is JoinableDataCollection) {
        path = this.path;
      } else {
        path = "joined/${this.rawPath.path.trimString(Const.slash)}";
      }
    }
    IDataCollection collection = PathMap.get<IDataCollection>(path);
    if (collection is JoinableDataCollection) {
      return collection.joinAt(
          key: key,
          builder: builder,
          prefix: prefix,
          onFound: onFound,
          onNotFound: onNotFound);
    } else {
      return JoinableDataCollection.from(path, this)?.joinAt(
          key: key,
          builder: builder,
          onFound: onFound,
          onNotFound: onNotFound,
          prefix: prefix);
    }
  }

  /// Add data to the original data.
  ///
  /// [path]: Path of JoinableDataCollection.
  /// If not specified, if the object being executed is a JoinaableDataCollection,
  /// the path is as it is, otherwise, joined is added to the beginning of the path.
  /// [test]: Callback for comparison.
  /// If True is returned, the data will be added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinWhere(
      {String path,
      String prefix,
      @required bool test(IDataDocument newField, IDataDocument oldField),
      @required Future<IDataCollection> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          String key, DataDocument value, IDataCollection collection)}) {
    if (isEmpty(path)) {
      if (this is JoinableDataCollection) {
        path = this.path;
      } else {
        path = "joined/${this.rawPath.path.trimString(Const.slash)}";
      }
    }
    IDataCollection collection = PathMap.get<IDataCollection>(path);
    if (collection is JoinableDataCollection) {
      return collection.joinWhere(
          test: test,
          builder: builder,
          prefix: prefix,
          onFound: onFound,
          onNotFound: onNotFound);
    } else {
      return JoinableDataCollection.from(path, this)?.joinWhere(
          test: test,
          builder: builder,
          prefix: prefix,
          onFound: onFound,
          onNotFound: onNotFound);
    }
  }

  /// Add data to the original data.
  ///
  /// [path]: Path of JoinableDataCollection.
  /// If not specified, if the object being executed is a JoinaableDataCollection,
  /// the path is as it is, otherwise, joined is added to the beginning of the path.
  /// [key]: The key of the data to compare.
  /// If the data of this key matches, that data is added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinDocumentAt(
      {String path,
      String prefix,
      @required String key,
      @required Future<IDataDocument> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document),
      void onNotFound(String key, DataDocument value)}) {
    if (isEmpty(path)) {
      if (this is JoinableDataCollection) {
        path = this.path;
      } else {
        path = "joined/${this.rawPath.path.trimString(Const.slash)}";
      }
    }
    IDataCollection collection = PathMap.get<IDataCollection>(path);
    if (collection is JoinableDataCollection) {
      return collection.joinDocumentAt(
          key: key,
          builder: builder,
          prefix: prefix,
          onFound: onFound,
          onNotFound: onNotFound);
    } else {
      return JoinableDataCollection.from(path, this)?.joinDocumentAt(
          key: key,
          builder: builder,
          prefix: prefix,
          onFound: onFound,
          onNotFound: onNotFound);
    }
  }

  /// Add data to the original data.
  ///
  /// [path]: Path of JoinableDataCollection.
  /// If not specified, if the object being executed is a JoinaableDataCollection,
  /// the path is as it is, otherwise, joined is added to the beginning of the path.
  /// [test]: Callback for comparison.
  /// If True is returned, the data will be added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinDocumentWhere(
      {String path,
      String prefix,
      @required bool test(IDataDocument newField, IDataDocument oldField),
      @required Future<IDataDocument> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document),
      void onNotFound(String key, DataDocument value)}) {
    if (isEmpty(path)) {
      if (this is JoinableDataCollection) {
        path = this.path;
      } else {
        path = "joined/${this.rawPath.path.trimString(Const.slash)}";
      }
    }
    IDataCollection collection = PathMap.get<IDataCollection>(path);
    if (collection is JoinableDataCollection) {
      return collection.joinDocumentWhere(
          test: test,
          builder: builder,
          prefix: prefix,
          onFound: onFound,
          onNotFound: onNotFound);
    } else {
      return JoinableDataCollection.from(path, this)?.joinDocumentWhere(
          test: test,
          builder: builder,
          prefix: prefix,
          onFound: onFound,
          onNotFound: onNotFound);
    }
  }
}

/// Class that extends Future<IDataCollection>.
extension FutureJoinableDataCollectionExtension<T extends IDataCollection>
    on Future<T> {
  /// Add data to the original data.
  ///
  /// [path]: Path of JoinableDataCollection.
  /// If not specified, if the object being executed is a JoinaableDataCollection,
  /// the path is as it is, otherwise, joined is added to the beginning of the path.
  /// [key]: The key of the data to compare.
  /// If the data of this key matches, that data is added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinAt(
      {String path,
      String prefix,
      @required String key,
      @required Future<IDataCollection> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          String key, DataDocument value, IDataCollection collection)}) {
    if (this == null) return null;
    return this.then((value) {
      if (isEmpty(path)) {
        if (value is JoinableDataCollection) {
          path = value.path;
        } else {
          path = "joined/${value.rawPath.path.trimString(Const.slash)}";
        }
      }
      IDataCollection collection = PathMap.get<IDataCollection>(path);
      if (collection is JoinableDataCollection) {
        return collection.joinAt(
            key: key,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      } else {
        return JoinableDataCollection.from(path, value)?.joinAt(
            key: key,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      }
    });
  }

  /// Add data to the original data.
  ///
  /// [path]: Path of JoinableDataCollection.
  /// If not specified, if the object being executed is a JoinaableDataCollection,
  /// the path is as it is, otherwise, joined is added to the beginning of the path.
  /// [test]: Callback for comparison.
  /// If True is returned, the data will be added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinWhere(
      {String path,
      String prefix,
      @required bool test(IDataDocument newField, IDataDocument oldField),
      @required Future<IDataCollection> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          String key, DataDocument value, IDataCollection collection)}) {
    if (this == null) return null;
    return this.then((value) {
      if (isEmpty(path)) {
        if (value is JoinableDataCollection) {
          path = value.path;
        } else {
          path = "joined/${value.rawPath.path.trimString(Const.slash)}";
        }
      }
      IDataCollection collection = PathMap.get<IDataCollection>(path);
      if (collection is JoinableDataCollection) {
        return collection.joinWhere(
            test: test,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      } else {
        return JoinableDataCollection.from(path, value)?.joinWhere(
            test: test,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      }
    });
  }

  /// Add data to the original data.
  ///
  /// [path]: Path of JoinableDataCollection.
  /// If not specified, if the object being executed is a JoinaableDataCollection,
  /// the path is as it is, otherwise, joined is added to the beginning of the path.
  /// [key]: The key of the data to compare.
  /// If the data of this key matches, that data is added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinDocumentAt(
      {String path,
      String prefix,
      @required String key,
      @required Future<IDataDocument> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document),
      void onNotFound(String key, DataDocument value)}) {
    if (this == null) return null;
    return this.then((value) {
      if (isEmpty(path)) {
        if (value is JoinableDataCollection) {
          path = value.path;
        } else {
          path = "joined/${value.rawPath.path.trimString(Const.slash)}";
        }
      }
      IDataCollection collection = PathMap.get<IDataCollection>(path);
      if (collection is JoinableDataCollection) {
        return collection.joinDocumentAt(
            key: key,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      } else {
        return JoinableDataCollection.from(path, value)?.joinDocumentAt(
            key: key,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      }
    });
  }

  /// Add data to the original data.
  ///
  /// [path]: Path of JoinableDataCollection.
  /// If not specified, if the object being executed is a JoinaableDataCollection,
  /// the path is as it is, otherwise, joined is added to the beginning of the path.
  /// [test]: Callback for comparison.
  /// If True is returned, the data will be added to the original data.
  /// [builder]: Callback to get the data.
  /// [onFound]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataCollection> joinDocumentWhere(
      {String path,
      String prefix,
      @required bool test(IDataDocument newField, IDataDocument oldField),
      @required Future<IDataDocument> builder(IDataCollection collection),
      void onFound(String key, DataDocument value, IDataDocument document),
      void onNotFound(String key, DataDocument value)}) {
    if (this == null) return null;
    return this.then((value) {
      if (isEmpty(path)) {
        if (value is JoinableDataCollection) {
          path = value.path;
        } else {
          path = "joined/${value.rawPath.path.trimString(Const.slash)}";
        }
      }
      IDataCollection collection = PathMap.get<IDataCollection>(path);
      if (collection is JoinableDataCollection) {
        return collection.joinDocumentWhere(
            test: test,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      } else {
        return JoinableDataCollection.from(path, value)?.joinDocumentWhere(
            test: test,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      }
    });
  }
}
