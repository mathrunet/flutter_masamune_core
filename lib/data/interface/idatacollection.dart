part of masamune.data;

/// Interface for creating a DataDocument collection.
///
/// The relationship between documents and collections is consistent with Firestore etc.,
/// so it is easy to handle as data.
///
/// Please implement and use.
abstract class IDataCollection<TDocument extends IDataDocument>
    implements
        ICollection<TDocument>,
        IDynamicCollection<TDocument>,
        ISortable {
  /// Order for sorting.
  OrderBy get orderBy;

  /// Order for sorting.
  ///
  /// [orderBy]: Order type.
  // set orderBy(OrderBy orderBy);

  /// Order for sorting.
  ///
  /// Apply when the first sort is equivalent.
  OrderBy get thenBy;

  /// Order for sorting.
  ///
  /// Apply when the first sort is equivalent.
  ///
  /// [orderBy]: Order type.
  // set thenBy(OrderBy orderBy);

  /// Compare key for sorting.
  String get orderByKey;

  /// Compare key for sorting.
  ///
  /// [key]: Key for sorting.
  // set orderByKey(String key);

  /// Compare key for sorting.
  ///
  /// Apply when the first sort is equivalent.
  String get thenByKey;

  /// Compare key for sorting.
  ///
  /// Apply when the first sort is equivalent.
  ///
  /// [key]: Key for sorting.
  // set thenByKey(String key);

  /// Get the data.
  ///
  /// [key]: Key for retrieving data.
  TDocument operator [](Object key);

  /// Update document data.
  Future<T> reload<T extends IDataCollection>();

  /// Read the following data.
  ///
  /// If you want to check whether the next data can be obtained,
  /// execute [canNext()].
  Future<T> next<T extends IDataCollection>();

  /// True if the next data is available.
  ///
  /// The next data is acquired by [next()].
  bool canNext();
}
