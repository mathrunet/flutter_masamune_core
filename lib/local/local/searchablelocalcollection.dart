part of masamune.local;

/// Search for a document through a specific key from a collection in your local database.
///
/// This class just loads and gets the value.
///
/// If you want to change the contents of the collection, please use Local Collection.
///
/// ```
/// SearchableLocalCollection col = SearchableLocalCollection.listen( "user/user" );
/// for( LocalDocument doc in col ) { ... }
/// String name = doc.getString( "name" );
/// newDocument["age"] = 18;
/// newDocument.save();
/// ```
class SearchableLocalCollection extends Collection<LocalDocument>
    with SortableDataCollectionMixin<LocalDocument>
    implements IDataCollection<LocalDocument>, ISearchable {
  /// The key that contains the Bigram data for the search.
  String get queryKey => this._queryKey;
  String _queryKey = "@search";

  /// Current search text.
  String get searchText => this._searchText;
  String _searchText;

  /// True while searching.
  @override
  bool get isSearching => false;

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      SearchableLocalCollection._(
          path: path,
          searchText: this.searchText,
          isTemporary: isTemporary,
          queryKey: this.queryKey,
          group: group,
          order: order,
          orderBy: this.orderBy,
          thenBy: this.thenBy,
          orderByKey: this.orderByKey,
          thenByKey: this.thenByKey) as T;

  /// Search for a document through a specific key from a collection in your local database.
  ///
  /// This class just loads and gets the value.
  ///
  /// If you want to change the contents of the collection, please use Local Collection.
  ///
  /// ```
  /// SearchableLocalCollection col = SearchableLocalCollection.listen( "user/user" );
  /// for( LocalDocument doc in col ) { ... }
  /// String name = doc.getString( "name" );
  /// newDocument["age"] = 18;
  /// newDocument.save();
  /// ```
  ///
  /// [path]: Collection path.
  factory SearchableLocalCollection(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    SearchableLocalCollection collection =
        PathMap.get<SearchableLocalCollection>(path);
    if (collection != null) return collection;
    Log.warning(
        "No data was found from the pathmap. Please execute [load()] first.");
    return null;
  }

  /// Search for a document through a specific key from a collection in your local database.
  ///
  /// This class just loads and gets the value.
  ///
  /// If you want to change the contents of the collection, please use Local Collection.
  ///
  /// ```
  /// SearchableLocalCollection col = SearchableLocalCollection.listen( "user/user" );
  /// for( LocalDocument doc in col ) { ... }
  /// String name = doc.getString( "name" );
  /// newDocument["age"] = 18;
  /// newDocument.save();
  /// ```
  ///
  /// [path]: Collection path.
  /// [queryKey]: Key to search.
  /// [searchText]: The text to search for.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  static SearchableLocalCollection load(String path,
      {String queryKey = "@search",
      String searchText,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    SearchableLocalCollection collection =
        PathMap.get<SearchableLocalCollection>(path);
    if (collection != null) {
      if (searchText != null) collection._searchText = searchText;
      if (queryKey != null) collection._queryKey = queryKey;
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      collection.reload();
      return collection;
    }
    collection = SearchableLocalCollection._(
        path: path,
        queryKey: queryKey,
        searchText: searchText,
        orderBy: orderBy,
        thenBy: thenBy,
        orderByKey: orderByKey,
        thenByKey: thenByKey);
    collection._loadFromPrefs();
    return collection;
  }

  SearchableLocalCollection._(
      {String path,
      String searchText,
      String queryKey = "@search",
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
    this._searchText = searchText;
    this._queryKey = queryKey;
    this.orderBy = orderBy;
    this.thenBy = thenBy;
    this.orderByKey = orderByKey;
    this.thenByKey = thenByKey;
  }

  /// Search the collection with [searchText].
  ///
  /// [searchText]: Search text.
  Future search<T extends ISearchable>(String searchText) {
    this._searchText = searchText;
    this._loadFromPrefs();
    return this.asFuture();
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
          if (!tmp.value.containsKey(this.queryKey)) continue;
          if (!(tmp.value[this.queryKey]
                  ?.toString()
                  ?.contains(this.searchText) ??
              false)) continue;
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

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.local;
}
