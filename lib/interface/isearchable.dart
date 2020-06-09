part of masamune.interface;

/// Interface to make it a searchable class.
abstract class ISearchable {
  /// True while searching.
  bool get isSearching;

  /// Current search text.
  String get searchText;

  /// Search the collection with [searchText].
  ///
  /// [searchText]: Search text.
  FutureOr search<T extends ISearchable>(String searchText);
}
