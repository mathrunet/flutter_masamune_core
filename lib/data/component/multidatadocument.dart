part of masamune.data;

/// Class that can handle multiple collections as one document.
///
/// By specifying [MultiDataDocumentScope]
/// you can read/write data while changing the conditions in the collection.
///
/// Data rewriting is not immediately reflected in each data,
/// and [save()] must be performed.
class MultiDataDocument extends Document<IDataField>
    with DataDocumentMixin<IDataField>
    implements IDataDocument<IDataField> {
  IDataCollection _collection;
  static Iterable<IDataField> _convertData(
      String path, IDataCollection data, MultiDataDocumentScope scope) {
    Map<String, dynamic> tmp = MapPool.get();
    data?.forEach((document) {
      if (document == null) return;
      if (scope != null && !scope._check(document)) return;
      tmp = tmp.duplicate(document.data);
    });
    List<DataField> list = ListPool.get();
    tmp?.forEach((key, value) {
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

  /// Document scope.
  MultiDataDocumentScope get scope => this._scope;

  /// Rewrite the Document scope.
  ///
  /// [scope]: Document scope.
  set scope(MultiDataDocumentScope scope) {
    this._scope = scope;
    this.reset();
  }

  MultiDataDocumentScope _scope;

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      DataDocument._(path: path, isTemporary: isTemporary) as T;

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.data;

  /// Class that can handle multiple collections as one document.
  ///
  /// By specifying [MultiDataDocumentScope]
  /// you can read/write data while changing the conditions in the collection.
  ///
  /// Data rewriting is not immediately reflected in each data,
  /// and [save()] must be performed.
  ///
  /// [path]: Document path.
  /// [collection]: Collection handled internally.
  /// [scope]: Scope setting.
  factory MultiDataDocument(String path, IDataCollection collection,
      {MultiDataDocumentScope scope}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    if (collection == null) {
      Log.error("The collection is invalid.");
      return null;
    }
    MultiDataDocument document = PathMap.get<MultiDataDocument>(path);
    if (document != null) {
      if (document._collection != collection) {
        document._collection?.unlisten(document._listenCollection);
        document._scope = scope;
        document._collection = collection;
        document.reset();
        document._collection?.listen(document._listenCollection);
      } else if (document._scope != scope) {
        document.scope = scope;
      }
      return document;
    }
    return MultiDataDocument._(
        path: path,
        children: _convertData(path, collection, scope),
        collection: collection,
        scope: scope);
  }

  /// Class that can handle multiple collections as one document.
  ///
  /// By specifying [MultiDataDocumentScope]
  /// you can read/write data while changing the conditions in the collection.
  ///
  /// Data rewriting is not immediately reflected in each data,
  /// and [save()] must be performed.
  ///
  /// [path]: Document path.
  /// [collection]: Collection handled internally.
  /// [scope]: Scope setting.
  static Future<MultiDataDocument> fromFuture(
      String path, Future<IDataCollection> collection,
      {MultiDataDocumentScope scope}) async {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return Future.delayed(Duration.zero);
    }
    if (collection == null) {
      Log.error("The collection is invalid.");
      return Future.delayed(Duration.zero);
    }
    IDataCollection data = await collection;
    if (data == null) {
      Log.error("The collection is invalid.");
      return Future.delayed(Duration.zero);
    }
    MultiDataDocument document = PathMap.get<MultiDataDocument>(path);
    if (document != null) {
      if (document._collection != data) {
        document._collection?.unlisten(document._listenCollection);
        document._scope = scope;
        document._collection = data;
        document.reset();
        document._collection?.listen(document._listenCollection);
      } else if (document._scope != scope) {
        document.scope = scope;
      }
      return document;
    }
    return MultiDataDocument._(
        path: path,
        children: _convertData(path, data, scope),
        collection: data,
        scope: scope);
  }

  MultiDataDocument._(
      {String path,
      Iterable<DataField> children,
      IDataCollection collection,
      MultiDataDocumentScope scope,
      bool isTemporary = false})
      : this._collection = collection,
        this._scope = scope,
        super(path, children: children, isTemporary: isTemporary) {
    this._collection?.listen(this._listenCollection);
  }

  void _listenCollection(IDataCollection collection) {
    if (collection.updatedTime <= this.updatedTime) return;
    this.set(_convertData(this.path, collection, this.scope));
  }

  /// Reset the data.
  MultiDataDocument reset() {
    this.data.clear();
    this.set(_convertData(this.path, this._collection, this.scope));
    return this;
  }

  /// Create a new field.
  ///
  /// [path]: Field path.
  /// [value]: Field value.
  @override
  @protected
  DataField createField([String path, value]) => DataField(path, value);

  /// Update document data.
  @override
  Future<T> reload<T extends IDataDocument>() async {
    List<Future> task = ListPool.get();
    for (IDataDocument doc in this._collection) {
      if (this.scope != null && !this.scope._check(doc)) continue;
      task.add(doc.reload());
    }
    if (task.length > 0) await Future.wait(task);
    this.reset();
    return this as T;
  }

  /// Save the data.
  ///
  /// Run if you have a remote or need to save data.
  Future<T> save<T extends IDataDocument>(
      {Map<String, dynamic> data, void builder(T document)}) async {
    List<Future> task = ListPool.get();
    for (IDataDocument doc in this._collection) {
      if (this.scope != null && !this.scope._check(doc)) continue;
      for (MapEntry<String, IDataField> tmp in this.data.entries) {
        if (isEmpty(tmp.key) || tmp.value == null) continue;
        doc[tmp.key] = tmp.value.data;
      }
      task.add(doc.save(data: data, builder: builder));
    }
    if (task.length > 0) await Future.wait(task);
    return this as T;
  }

  /// Delete the data.
  ///
  /// Used when deleting data when there is a remote or when data needs to be saved.
  Future delete() async {
    List<Future> task = ListPool.get();
    for (IDataDocument doc in this._collection) {
      if (this.scope != null && !this.scope._check(doc)) continue;
      task.add(doc.delete());
    }
    if (task.length > 0) await Future.wait(task);
  }
}

/// Scope setting used in [MultiDataDocument].
class MultiDataDocumentScope {
  bool _check(IDataDocument document) {
    if (document == null) return false;
    if (isNotEmpty(this.id) && document.id == this.id) return true;
    if (isNotEmpty(this.path) && document.path == this.path) return true;
    if (this.document != null &&
        (document == this.document || document.path == this.document.path))
      return true;
    if (this.idList != null && this.idList.contains(document.id)) return true;
    if (this.pathList != null && this.pathList.contains(document.path))
      return true;
    if (this.documentList != null &&
        this.documentList.any((element) =>
            element == document || element?.path == document?.path))
      return true;
    if (this.predicate != null && this.predicate(document)) return true;
    return false;
  }

  /// The specified ID.
  final String id;

  /// The specified path.
  final String path;

  /// The specified document.
  final IDataDocument document;

  /// The specified ID list.
  final List<String> idList;

  /// The specified path list.
  final List<String> pathList;

  /// The specified document list.
  final List<IDataDocument> documentList;

  /// The condition to specify. If True, it is scoped.
  final bool Function(IDataDocument document) predicate;

  /// Scope setting used in [MultiDataDocument].
  ///
  /// [id]: The specified ID.
  const MultiDataDocumentScope.id(this.id)
      : this.path = null,
        this.document = null,
        this.pathList = null,
        this.idList = null,
        this.documentList = null,
        this.predicate = null,
        assert(id != null);

  /// Scope setting used in [MultiDataDocument].
  ///
  /// [path]: The specified path.
  const MultiDataDocumentScope.path(this.path)
      : this.id = null,
        this.document = null,
        this.pathList = null,
        this.idList = null,
        this.documentList = null,
        this.predicate = null,
        assert(path != null);

  /// Scope setting used in [MultiDataDocument].
  ///
  /// [document]: The specified document.
  const MultiDataDocumentScope.document(this.document)
      : this.id = null,
        this.path = null,
        this.pathList = null,
        this.idList = null,
        this.documentList = null,
        this.predicate = null,
        assert(document != null);

  /// Scope setting used in [MultiDataDocument].
  ///
  /// [pathList]: The specified path list.
  const MultiDataDocumentScope.pathList(this.pathList)
      : this.id = null,
        this.path = null,
        this.document = null,
        this.idList = null,
        this.documentList = null,
        this.predicate = null,
        assert(pathList != null);

  /// Scope setting used in [MultiDataDocument].
  ///
  /// [idList]: The specified ID list.
  const MultiDataDocumentScope.idList(this.idList)
      : this.id = null,
        this.path = null,
        this.document = null,
        this.pathList = null,
        this.documentList = null,
        this.predicate = null,
        assert(idList != null);

  /// Scope setting used in [MultiDataDocument].
  ///
  /// [documentList]: The specified document list.
  const MultiDataDocumentScope.documentList(this.documentList)
      : this.id = null,
        this.path = null,
        this.document = null,
        this.pathList = null,
        this.idList = null,
        this.predicate = null,
        assert(documentList != null);

  /// Scope setting used in [MultiDataDocument].
  ///
  /// [predicate]: The condition to specify. If True, it is scoped.
  const MultiDataDocumentScope.where(this.predicate)
      : this.id = null,
        this.path = null,
        this.document = null,
        this.pathList = null,
        this.documentList = null,
        this.idList = null,
        assert(predicate != null);
}
