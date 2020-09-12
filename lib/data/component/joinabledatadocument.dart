part of masamune.data;

/// Class for adding new data to a data document.
///
/// The added data is stored in
/// a different path to distinguish it from the original data.
///
/// ```
/// JoinableDataDocument.from("joined/data", firestoreDocument)
/// .request(key:"id", builder: (document) => DataDocument("source"));
/// ```
class JoinableDataDocument extends TaskDocument<DataField>
    with DataDocumentMixin<DataField>
    implements IDataDocument<DataField> {
  static Iterable<DataField> _convertData(String path, IDataDocument data) {
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

  IDataDocument _source;
  List<_DocumentJoinEntry> _listener = ListPool.get();

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class
  @override
  Completer createCompleter() => Completer<JoinableDataDocument>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      JoinableDataDocument._(path: path, isTemporary: false) as T;

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.data;

  /// Create a new field.
  ///
  /// [path]: Field path.
  /// [value]: Field value.
  @override
  DataField createField([String path, value]) => DataField(path, value);

  /// Class for adding new data to a data document.
  ///
  /// The added data is stored in
  /// a different path to distinguish it from the original data.
  ///
  /// ```
  /// JoinableDataDocument.from("joined/data", firestoreDocument)
  /// .request(key:"id", builder: (document) => DataDocument("source"));
  /// ```
  ///
  /// [path]: The path.
  factory JoinableDataDocument(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    JoinableDataDocument document = PathMap.get<JoinableDataDocument>(path);
    if (document != null) return document;
    Log.warning(
        "No data was found from the pathmap. Please execute [listen()] first.");
    return null;
  }

  /// Class for adding new data to a data document.
  ///
  /// The added data is stored in
  /// a different path to distinguish it from the original data.
  ///
  /// ```
  /// JoinableDataDocument.from("joined/data", firestoreDocument)
  /// .request(key:"id", builder: (document) => DataDocument("source"));
  /// ```
  ///
  /// Create a JoinableDataDocument from the data source.
  ///
  /// [path]: The path.
  /// [source]: Data source.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  static JoinableDataDocument from(String path, IDataDocument source,
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
    JoinableDataDocument document = PathMap.get<JoinableDataDocument>(path);
    if (document != null) {
      if (source != null) {
        if (source != document && source.path != document.path) {
          document._setInternal(
              source: source, children: _convertData(path, source));
        }
      }
      return document;
    }
    document = JoinableDataDocument._(
        path: path, source: source, children: _convertData(path, source));
    return document;
  }

  void _listenUpdate(IPath collection) async {
    if (this._source != null) {
      this._source.forEach((key, value) {
        if (this.data.containsKey(key)) {
          this.data[key].data = value.data;
        } else {
          DataField(Paths.child(path, key), value.data);
        }
      });
      this
          .data
          .removeWhere((key, value) => !this._source.data.keys.contains(key));
      this._setInternal(
          source: this._source,
          children: _convertData(this.path, this._source));
    }
    for (_DocumentJoinEntry entry in this._listener) {
      if (entry == null) continue;
      if (entry is _DocumentJoinDocumentEntry) {
        await entry.rebuild(this, this._listenUpdate);
        if (entry.document == null || entry.document.isDisposed) continue;
        this._applyDocumentInternal(
            prefix: entry.prefix,
            document: entry.document,
            onApply: entry.onApply);
      } else if (entry is _DocumentJoinCollectionEntry) {
        await entry.rebuild(this, this._listenUpdate);
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

  void _setInternal({IDataDocument source, Iterable<DataField> children}) {
    this.data.clear();
    if (this._source != source) {
      if (this._source != null) this._source.unlisten(this._listenUpdate);
      this._source = source;
      if (this._source != null) this._source.listen(this._listenUpdate);
    }
    if (children != null) {
      for (DataField unit in children) {
        if (unit == null) continue;
        this.setInternal(unit);
      }
    }
  }

  JoinableDataDocument._(
      {String path,
      IDataDocument source,
      Iterable<DataField> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super(
            path: path,
            children: children,
            isTemporary: isTemporary,
            group: group,
            order: order) {
    this._source = source;
    if (this._source != null) this._source.listen(this._listenUpdate);
  }

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  @override
  void dispose() {
    if (this.isDisposed || !this.isDisposable) return;
    if (this._source != null) this._source.unlisten(this._listenUpdate);
    this._listener?.forEach((element) {
      if (element is _DocumentJoinDocumentEntry) {
        element?.document?.unlisten(this._listenUpdate);
      } else if (element is _DocumentJoinCollectionEntry) {
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
  Future<JoinableDataDocument> joinCollectionAt(
      {@required String key,
      @required Future<IDataCollection> builder(IDataDocument document),
      void onFound(JoinableDataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(JoinableDataDocument value, IDataCollection collection),
      String prefix}) async {
    assert(isNotEmpty(key));
    assert(builder != null);
    if (builder == null) return this;
    if (isEmpty(key)) return this;
    this.init();
    IDataCollection collection = await builder(this);
    if (collection == null) return this;
    if (!this._listener.any((entry) =>
        entry is _DocumentJoinCollectionEntry &&
        (entry.collection == collection ||
            entry.collection.path == collection.path))) {
      collection.listen(this._listenUpdate);
      this._listener.add(_DocumentJoinCollectionEntry(
          key: key,
          prefix: prefix,
          collection: collection,
          builder: builder,
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
  Future<JoinableDataDocument> joinCollectionWhere(
      {@required bool test(IDataDocument original, IDataDocument additional),
      @required Future<IDataCollection> builder(IDataDocument document),
      void onFound(JoinableDataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(JoinableDataDocument value, IDataCollection collection),
      String prefix}) async {
    assert(test != null);
    assert(builder != null);
    if (builder == null) return this;
    if (test == null) return this;
    this.init();
    IDataCollection collection = await builder(this);
    if (collection == null) return this;
    if (!this._listener.any((entry) =>
        entry is _DocumentJoinCollectionEntry &&
        (entry.collection == collection ||
            entry.collection.path == collection.path))) {
      collection.listen(this._listenUpdate);
      this._listener.add(_DocumentJoinCollectionEntry(
          test: test,
          prefix: prefix,
          collection: collection,
          builder: builder,
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
  /// [builder]: Callback to get the data.
  /// [onApply]: Callback for applying data. If not, it overwrites all values.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataDocument> joinAt(
      {String prefix,
      @required Future<IDataDocument> builder(IDataDocument document),
      void onApply(JoinableDataDocument value, IDataDocument document)}) async {
    assert(builder != null);
    if (builder == null) return this;
    this.init();
    IDataDocument document = await builder(this);
    assert(document != this && document.path != this.path);
    if (document == this || document.path == this.path) {
      this.error("Cannot specify yourself for a joined document.");
      return this;
    }
    if (document == null) return this;
    if (!this._listener.any((entry) =>
        entry is _DocumentJoinDocumentEntry &&
        (entry.document == document || entry.document.path == document.path))) {
      document.listen(this._listenUpdate);
      this._listener.add(_DocumentJoinDocumentEntry(
          prefix: prefix,
          document: document,
          onApply: onApply,
          builder: builder));
    }
    this._applyDocumentInternal(
        prefix: prefix, document: document, onApply: onApply);
    this.done();
    return this;
  }

  void _applyCollectionInternal(
      {String key,
      String prefix,
      bool test(IDataDocument original, IDataDocument additional),
      void onFound(JoinableDataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(JoinableDataDocument value, IDataCollection collection),
      IDataCollection collection}) {
    if (isNotEmpty(key)) {
      if (!this.data.containsKey(key)) return;
      IDataDocument doc = collection.firstWhere(
          (element) =>
              element.containsKey(key) && this.data[key].data == element[key],
          orElse: () => null);
      if (doc == null) {
        if (onNotFound != null) onNotFound(this, collection);
        return;
      }
      if (onFound != null) {
        onFound(this, doc, collection);
      } else {
        for (MapEntry<String, IDataField> data in doc.entries) {
          if (isEmpty(data.key) || data.value == null) continue;
          String key = data.key;
          if (isNotEmpty(prefix)) key = prefix + key;
          this[key] = data.value.data;
        }
      }
    } else if (test != null) {
      IDataDocument doc = collection
          .firstWhere((element) => test(this, element), orElse: () => null);
      if (doc == null) {
        if (onNotFound != null) onNotFound(this, collection);
        return;
      }
      if (onFound != null) {
        onFound(this, doc, collection);
      } else {
        for (MapEntry<String, IDataField> data in doc.entries) {
          if (isEmpty(data.key) || data.value == null) continue;
          String key = data.key;
          if (isNotEmpty(prefix)) key = prefix + key;
          this[key] = data.value.data;
        }
      }
    }
  }

  void _applyDocumentInternal(
      {String prefix,
      void onApply(JoinableDataDocument value, IDataDocument document),
      IDataDocument document}) {
    if (onApply != null) {
      onApply(this, document);
    } else {
      for (MapEntry<String, IDataField> data in document.entries) {
        if (isEmpty(data.key) || data.value == null) continue;
        String key = data.key;
        if (isNotEmpty(prefix)) key = prefix + key;
        this[key] = data.value.data;
      }
    }
  }
}

abstract class _DocumentJoinEntry {
  final String prefix;
  _DocumentJoinEntry({this.prefix});
}

class _DocumentJoinDocumentEntry extends _DocumentJoinEntry {
  final void Function(JoinableDataDocument value, IDataDocument document)
      onApply;
  IDataDocument document;
  final Future<IDataDocument> Function(IDataDocument document) builder;
  _DocumentJoinDocumentEntry(
      {String key, String prefix, this.document, this.onApply, this.builder})
      : super(prefix: prefix);
  Future<IDataDocument> rebuild(
      IDataDocument document, void Function(IDataDocument) callback) async {
    IDataDocument res = await builder(document);
    if (res == null) return this.document;
    this.document?.unlisten(callback);
    res.listen(callback);
    this.document = res;
    return this.document;
  }
}

class _DocumentJoinCollectionEntry extends _DocumentJoinEntry {
  final String key;
  final bool Function(IDataDocument original, IDataDocument additional) test;
  final void Function(JoinableDataDocument value, IDataDocument document,
      IDataCollection collection) onFound;
  final void Function(JoinableDataDocument value, IDataCollection collection)
      onNotFound;
  IDataCollection collection;
  final Future<IDataCollection> Function(IDataDocument document) builder;
  _DocumentJoinCollectionEntry(
      {this.key,
      String prefix,
      this.test,
      this.collection,
      this.builder,
      this.onFound,
      this.onNotFound})
      : super(prefix: prefix);
  Future<IDataCollection> rebuild(
      IDataDocument document, void Function(IDataCollection) callback) async {
    IDataCollection res = await builder(document);
    if (res == null) return this.collection;
    this.collection?.unlisten(callback);
    res.listen(callback);
    this.collection = res;
    return this.collection;
  }
}

/// Class that extends IDataDocument.
extension JoinableDataDocumentExtension<T extends IDataDocument> on T {
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
  Future<JoinableDataDocument> joinCollectionAt(
      {String path,
      String prefix,
      @required String key,
      @required Future<IDataCollection> builder(IDataDocument document),
      void onFound(JoinableDataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          JoinableDataDocument value, IDataCollection collection)}) {
    if (isEmpty(path)) {
      if (this is JoinableDataDocument) {
        path = this.path;
      } else {
        path = "joined/${this.rawPath.path.trimString(Const.slash)}";
      }
    }
    IDataDocument document = PathMap.get<IDataDocument>(path);
    if (document is JoinableDataDocument) {
      return document.joinCollectionAt(
          key: key,
          builder: builder,
          prefix: prefix,
          onFound: onFound,
          onNotFound: onNotFound);
    } else {
      return JoinableDataDocument.from(path, this)?.joinCollectionAt(
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
  Future<JoinableDataDocument> joinCollectionWhere(
      {String path,
      String prefix,
      @required bool test(IDataDocument original, IDataDocument additional),
      @required Future<IDataCollection> builder(IDataDocument document),
      void onFound(JoinableDataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          JoinableDataDocument value, IDataCollection collection)}) {
    if (isEmpty(path)) {
      if (this is JoinableDataDocument) {
        path = this.path;
      } else {
        path = "joined/${this.rawPath.path.trimString(Const.slash)}";
      }
    }
    IDataDocument document = PathMap.get<IDataDocument>(path);
    if (document is JoinableDataDocument) {
      return document.joinCollectionWhere(
          test: test,
          builder: builder,
          prefix: prefix,
          onFound: onFound,
          onNotFound: onNotFound);
    } else {
      return JoinableDataDocument.from(path, this)?.joinCollectionWhere(
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
  /// [builder]: Callback to get the data.
  /// [onApply]: Callback for applying data. If not, it overwrites all values.
  /// [onNotFound]: Processing when no data is found.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataDocument> joinAt(
      {String path,
      String prefix,
      @required Future<IDataDocument> builder(IDataDocument document),
      void onApply(JoinableDataDocument value, IDataDocument document)}) {
    if (isEmpty(path)) {
      if (this is JoinableDataDocument) {
        path = this.path;
      } else {
        path = "joined/${this.rawPath.path.trimString(Const.slash)}";
      }
    }
    IDataDocument document = PathMap.get<IDataDocument>(path);
    if (document is JoinableDataDocument) {
      return document.joinAt(
          builder: builder, prefix: prefix, onApply: onApply);
    } else {
      return JoinableDataDocument.from(path, this)
          ?.joinAt(builder: builder, prefix: prefix, onApply: onApply);
    }
  }
}

/// Class that extends Future<IDataDocument>.
extension FutureJoinableDataDocumentExtension<T extends IDataDocument>
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
  Future<JoinableDataDocument> joinCollectionAt(
      {String path,
      String prefix,
      @required String key,
      @required Future<IDataCollection> builder(IDataDocument document),
      void onFound(JoinableDataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          JoinableDataDocument value, IDataCollection collection)}) {
    if (this == null) return null;
    return this.then((value) {
      if (isEmpty(path)) {
        if (value is JoinableDataDocument) {
          path = value.path;
        } else {
          path = "joined/${value.rawPath.path.trimString(Const.slash)}";
        }
      }
      IDataDocument document = PathMap.get<IDataDocument>(path);
      if (document is JoinableDataDocument) {
        return document.joinCollectionAt(
            key: key,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      } else {
        return JoinableDataDocument.from(path, value)?.joinCollectionAt(
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
  Future<JoinableDataDocument> joinCollectionWhere(
      {String path,
      String prefix,
      @required bool test(IDataDocument original, IDataDocument additional),
      @required Future<IDataCollection> builder(IDataDocument document),
      void onFound(JoinableDataDocument value, IDataDocument document,
          IDataCollection collection),
      void onNotFound(
          JoinableDataDocument value, IDataCollection collection)}) {
    if (this == null) return null;
    return this.then((value) {
      if (isEmpty(path)) {
        if (value is JoinableDataDocument) {
          path = value.path;
        } else {
          path = "joined/${value.rawPath.path.trimString(Const.slash)}";
        }
      }
      IDataDocument document = PathMap.get<IDataDocument>(path);
      if (document is JoinableDataDocument) {
        return document.joinCollectionWhere(
            test: test,
            builder: builder,
            prefix: prefix,
            onFound: onFound,
            onNotFound: onNotFound);
      } else {
        return JoinableDataDocument.from(path, value)?.joinCollectionWhere(
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
  /// [builder]: Callback to get the data.
  /// [onApply]: Callback for applying data. If not, it overwrites all values.
  /// [prefix]: Prefix key that is prepended to the applied data.
  Future<JoinableDataDocument> joinAt(
      {String path,
      String prefix,
      @required Future<IDataDocument> builder(IDataDocument document),
      void onApply(JoinableDataDocument value, IDataDocument document)}) {
    if (this == null) return null;
    return this.then((value) {
      if (isEmpty(path)) {
        if (value is JoinableDataDocument) {
          path = value.path;
        } else {
          path = "joined/${value.rawPath.path.trimString(Const.slash)}";
        }
      }
      IDataDocument document = PathMap.get<IDataDocument>(path);
      if (document is JoinableDataDocument) {
        return document.joinAt(
            builder: builder, prefix: prefix, onApply: onApply);
      } else {
        return JoinableDataDocument.from(path, value)
            ?.joinAt(builder: builder, prefix: prefix, onApply: onApply);
      }
    });
  }
}
