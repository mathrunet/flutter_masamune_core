part of masamune.model;

/// This model allows
/// you to save data in the device and use it as a collection.
class SearchableLocalCollectionModel extends CollectionModel {
  String _searchText;

  /// Search text.
  String get searchText => this._searchText ?? this.defaultSearchText;

  /// Search text.
  set searchText(String value) {
    if (value == this.searchText) return;
    this._searchText = value;
    this.rebuild();
  }

  /// The query key to perform the search.
  final String queryKey;

  /// Default search text.
  final String defaultSearchText;

  /// This model allows
  /// you to save data in the device and use it as a collection.
  SearchableLocalCollectionModel(String path,
      {this.queryKey = "@search",
      this.defaultSearchText,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : super(
          path,
          orderBy: orderBy,
          thenBy: thenBy,
          orderByKey: orderByKey,
          thenByKey: thenByKey,
        );

  /// Build the model.
  ///
  /// The [context] section contains the context needed for the model.
  ///
  /// You can return [Exposed] to reflect the data in it in the model.
  @override
  FutureOr build(ModelContext context) {
    return SearchableLocalCollection.load(
      path,
      queryKey: this.queryKey,
      orderBy: this.orderBy,
      thenBy: this.thenBy,
      orderByKey: this.orderByKey,
      thenByKey: this.thenByKey,
      searchText: this.searchText,
    );
  }
}
