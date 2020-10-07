part of masamune.data;

/// Abstract class for mixin that gives sorting function to collection that handles DataDocument.
///
/// Please mix in and use.
mixin SortableDataCollectionMixin<T extends IDataDocument> on ICollection<T>
    implements IDataCollection<T> {
  /// Order for sorting.
  OrderBy get orderBy => this._orderBy;

  /// Order for sorting.
  ///
  /// [orderBy]: Order type.
  set orderBy(OrderBy orderBy) => this._orderBy = orderBy;
  OrderBy _orderBy = OrderBy.none;

  /// Order for sorting.
  ///
  /// Apply when the first sort is equivalent.
  OrderBy get thenBy => this._thenBy;

  /// Order for sorting.
  ///
  /// Apply when the first sort is equivalent.
  ///
  /// [orderBy]: Order type.
  set thenBy(OrderBy orderBy) => this._thenBy = orderBy;
  OrderBy _thenBy = OrderBy.none;

  /// Compare key for sorting.
  String get orderByKey => this._orderByKey;

  /// Compare key for sorting.
  ///
  /// [key]: Key for sorting.
  set orderByKey(String key) => this._orderByKey = key;
  String _orderByKey;

  /// Compare key for sorting.
  ///
  /// Apply when the first sort is equivalent.
  String get thenByKey => this._thenByKey;

  /// Compare key for sorting.
  ///
  /// Apply when the first sort is equivalent.
  ///
  /// [key]: Key for sorting.
  set thenByKey(String key) => this._thenByKey = key;
  String _thenByKey;

  /// True if the sort data has changed.
  bool isChanged(
      {OrderBy orderBy, OrderBy thenBy, String orderByKey, String thenByKey}) {
    bool changed = false;
    if (orderBy != OrderBy.none && orderBy != this.orderBy) {
      changed = true;
      this.orderBy = orderBy;
    }
    if (thenBy != OrderBy.none && thenBy != this.thenBy) {
      changed = true;
      this.thenBy = thenBy;
    }
    if (isNotEmpty(orderByKey) && orderByKey != this.orderByKey) {
      changed = true;
      this.orderByKey = orderByKey;
    }
    if (isNotEmpty(thenByKey) && thenByKey != this.thenByKey) {
      changed = true;
      this.thenByKey = thenByKey;
    }
    return changed;
  }

  /// Sort according to the sort setting.
  ///
  /// [orderBy] and [orderByKey], [thenBy] and [thenByKey] as the sort contents.
  void sort() => this.data.sort(this._sortAction);
  int _sortAction(MapEntry<String, T> a, MapEntry<String, T> b) {
    int r = 0;
    if (a.value != null &&
        b.value != null &&
        a.value.containsKey(this.orderByKey) &&
        b.value.containsKey(this.orderByKey)) {
      if (this.orderBy == OrderBy.asc) {
        if (a.value[this.orderByKey] is double) {
          r = a.value
              .getDouble(this.orderByKey)
              .compareTo(b.value.getDouble(this.orderByKey));
        } else if (a.value[this.orderByKey] is int) {
          r = a.value
              .getInt(this.orderByKey)
              .compareTo(b.value.getInt(this.orderByKey));
        } else if (a.value[this.orderByKey] is bool) {
          r = a.value
              .getBool(this.orderByKey)
              .compareTo(b.value.getBool(this.orderByKey));
        } else {
          r = a.value
              .getString(this.orderByKey)
              .compareTo(b.value.getString(this.orderByKey));
        }
      } else {
        if (a.value[this.orderByKey] is double) {
          r = b.value
              .getDouble(this.orderByKey)
              .compareTo(a.value.getDouble(this.orderByKey));
        } else if (a.value[this.orderByKey] is int) {
          r = b.value
              .getInt(this.orderByKey)
              .compareTo(a.value.getInt(this.orderByKey));
        } else if (a.value[this.orderByKey] is bool) {
          r = b.value
              .getBool(this.orderByKey)
              .compareTo(a.value.getBool(this.orderByKey));
        } else {
          r = b.value
              .getString(this.orderByKey)
              .compareTo(a.value.getString(this.orderByKey));
        }
      }
    } else if (a.value == null || !a.value.containsKey(this.orderByKey)) {
      if (this.orderBy == OrderBy.asc) {
        r = -1;
      } else {
        r = 1;
      }
    } else if (b.value == null || !b.value.containsKey(this.orderByKey)) {
      if (this.orderBy == OrderBy.asc) {
        r = 1;
      } else {
        r = -1;
      }
    }
    if (r == 0 && this.thenBy != OrderBy.none && !isEmpty(this.thenByKey)) {
      if (a.value != null &&
          b.value != null &&
          a.value.containsKey(this.thenByKey) &&
          b.value.containsKey(this.thenByKey)) {
        if (this.thenBy == OrderBy.asc) {
          if (a.value[this.thenByKey] is double) {
            r = a.value
                .getDouble(this.thenByKey)
                .compareTo(b.value.getDouble(this.thenByKey));
          } else if (a.value[this.thenByKey] is int) {
            r = a.value
                .getInt(this.thenByKey)
                .compareTo(b.value.getInt(this.thenByKey));
          } else if (a.value[this.thenByKey] is bool) {
            r = a.value
                .getBool(this.thenByKey)
                .compareTo(b.value.getBool(this.thenByKey));
          } else {
            r = a.value
                .getString(this.thenByKey)
                .compareTo(b.value.getString(this.thenByKey));
          }
        } else {
          if (a.value[this.thenByKey] is double) {
            r = b.value
                .getDouble(this.thenByKey)
                .compareTo(a.value.getDouble(this.thenByKey));
          } else if (a.value[this.thenByKey] is int) {
            r = b.value
                .getInt(this.thenByKey)
                .compareTo(a.value.getInt(this.thenByKey));
          } else if (a.value[this.thenByKey] is bool) {
            r = b.value
                .getBool(this.thenByKey)
                .compareTo(a.value.getBool(this.thenByKey));
          } else {
            r = b.value
                .getString(this.thenByKey)
                .compareTo(a.value.getString(this.thenByKey));
          }
        }
      } else if (a.value == null || !a.value.containsKey(this.thenByKey)) {
        if (this.thenBy == OrderBy.asc) {
          r = -1;
        } else {
          r = 1;
        }
      } else if (b.value == null || !b.value.containsKey(this.thenByKey)) {
        if (this.thenBy == OrderBy.asc) {
          r = 1;
        } else {
          r = -1;
        }
      }
    }
    return r;
  }

  /// Update document data.
  Future<T> reload<T extends IDataCollection>() =>
      Future<T>.delayed(Duration.zero);

  /// Read the following data.
  ///
  /// If you want to check whether the next data can be obtained,
  /// execute [canNext()].
  Future<T> next<T extends IDataCollection>() =>
      Future<T>.delayed(Duration.zero);

  /// True if the next data is available.
  ///
  /// The next data is acquired by [next()].
  bool canNext() => false;
}
