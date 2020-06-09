part of masamune.data;

/// Create a searchable collection.
///
/// By specifying [onSearch], you can query the API during the search and wait for the result.
/// During that time, the data will be initialized.
///
/// Start the search with the [search] method.
///
/// Others are the same as [MultiDataCollection].
class SearchableMultiDataCollection extends MultiDataCollection
    implements ISearchable {
  Iterable<String> _retrieveKeys;

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      SearchableMultiDataCollection._(
          path: path,
          searchText: this.searchText,
          collections: this._collection,
          orderBy: this.orderBy,
          orderByKey: this.orderByKey,
          thenBy: this.thenBy,
          thenByKey: this.thenByKey) as T;

  /// Create a searchable collection.
  ///
  /// By specifying [onSearch], you can query the API during the search and wait for the result.
  /// During that time, the data will be initialized.
  ///
  /// Start the search with the [search] method.
  ///
  /// Others are the same as [MultiDataCollection].
  ///
  /// [path]: Collection path.
  /// [collections]: The collection to store.
  /// [retrieveKeys]: Target key to search.
  /// [searchText]: Initial search text.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  factory SearchableMultiDataCollection(String path,
      {Iterable<IDataCollection> collections = const [],
      String searchText,
      Iterable<String> retrieveKeys = const ["name", "text", "tag", "search"],
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
    SearchableMultiDataCollection collection =
        PathMap.get<SearchableMultiDataCollection>(path);
    if (collection != null) {
      if (searchText != null) collection._searchText = searchText;
      if (retrieveKeys != null) collection._retrieveKeys = retrieveKeys;
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
    return SearchableMultiDataCollection._(
        path: path,
        searchText: searchText,
        retrieveKeys: retrieveKeys,
        collections: collections,
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }

  /// Create a searchable collection.
  ///
  /// By specifying [onSearch], you can query the API during the search and wait for the result.
  /// During that time, the data will be initialized.
  ///
  /// Start the search with the [search] method.
  ///
  /// Others are the same as [MultiDataCollection].
  ///
  /// [path]: Collection path.
  /// [collectionsFuture]: The collection to store.
  /// [searchText]: Initial search text.
  /// [collections]: The collection to store.
  /// [retrieveKeys]: Target key to search.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  static Future<SearchableMultiDataCollection> fromFuture(String path,
      {Iterable<Future<IDataCollection>> collections = const [],
      String searchText,
      Iterable<String> retrieveKeys = const ["name", "text", "tag", "search"],
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
    SearchableMultiDataCollection collection =
        PathMap.get<SearchableMultiDataCollection>(path);
    if (collection != null) {
      if (searchText != null) collection._searchText = searchText;
      if (retrieveKeys != null) collection._retrieveKeys = retrieveKeys;
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
    return SearchableMultiDataCollection._(
        path: path,
        searchText: searchText,
        retrieveKeys: retrieveKeys,
        collections: tmp,
        orderBy: orderBy,
        orderByKey: orderByKey,
        thenBy: thenBy,
        thenByKey: thenByKey);
  }

  SearchableMultiDataCollection._(
      {String path,
      String searchText,
      Iterable<IDataCollection> collections = const [],
      Iterable<String> retrieveKeys = const ["name", "text", "tag", "search"],
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey,
      bool isTemporary})
      : this._searchText = searchText,
        this._retrieveKeys = retrieveKeys,
        super._(
            path: path,
            collections: collections,
            orderBy: orderBy,
            thenBy: thenBy,
            orderByKey: orderByKey,
            thenByKey: thenByKey,
            isTemporary: isTemporary);
  @override
  void _build() {
    if (this._collection == null || this._collection.length <= 0) return;
    this.clear();
    this._filtering();
  }

  /// True while searching.
  bool get isSearching => this._isSearching;
  bool _isSearching;

  /// Current search text.
  String get searchText => this._searchText;

  /// Search the data.
  ///
  /// [text]: Search text.
  Future search<T extends ISearchable>(String text) async {
    if (this._collection == null || this._collection.length <= 0)
      return this as T;
    try {
      this._isSearching = true;
      this._searchText = text;
      this.clear();
      if (isEmpty(text)) {
        this._filtering();
        this._isSearching = false;
        return this as T;
      }
      await this
          ._collection
          .map<Future>((col) {
            if (!(col is ISearchable)) return null;
            return col?.asType<ISearchable>()?.search(text);
          })
          ?.mapAsync()
          ?.toList();
      this._filtering();
    } catch (e) {
      Log.error(e.toString());
    }
    this._isSearching = false;
    return this as T;
  }

  void _filtering() {
    if (isEmpty(this._searchText)) {
      for (IDataCollection collection in this._collection) {
        if (collection == null) continue;
        for (IDataDocument document in collection) {
          if (document == null) continue;
          this.setInternal(document);
        }
      }
    } else {
      List<String> search = this._searchText.toLowerCase().split(Const.space);
      for (IDataCollection collection in this._collection) {
        if (collection == null) continue;
        for (IDataDocument document in collection) {
          if (document == null) continue;
          if (search.length > 0) {
            if (!this._retrieveKeys.any((retrieve) => search.any((s) =>
                document.getString(retrieve)?.toLowerCase()?.contains(s) ??
                false))) continue;
          }
          this.setInternal(document);
        }
      }
    }
    this.sort();
  }

  String _searchText;
}
