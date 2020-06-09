part of masamune.path;

/// Attach a data filter to the IPath object.
///
/// It is possible to process data by passing a filter when inputting and outputting data.
///
/// ```
/// PathFilter.insertGetFilter( "data/user",  ( data ) => data + " is user's data." );
/// PathFilter.insertSetFilter( "data/user",  ( data ) => data.data = "Processed" );
/// ```
class PathFilter {
  static Map<String, List<_FilterPath>> _onGetFilter = MapPool.get();
  static Map<String, List<_FilterPath>> _onSetFilter = MapPool.get();
  static Map _processingCache = MapPool.get();

  /// Get the temporary data in the filter.
  ///
  /// [path]: Path to get temporary data.
  static dynamic getTemporary(String path) {
    if (isEmpty(path) || !_processingCache.containsKey(path)) return null;
    return _processingCache[path];
  }

  /// Get the temporary data in the filter.
  ///
  /// [path]: Path to get temporary data.
  static bool setTemporary(String path, dynamic value) {
    if (isEmpty(path) || !_processingCache.containsKey(path)) return false;
    return (_processingCache[path] = value) != null;
  }

  /// Apply a get filter for a specific path.
  ///
  /// By specifying a region, you can apply a filter that is limited to the region.
  ///
  /// [path]: The path to apply the filter to.
  /// [value]: Data to filter.
  /// [region]: Region to apply the filter to.
  static TValue applyGetFilter<TValue>(String path, TValue value,
      {String region}) {
    if (isEmpty(path)) return value;
    _processingCache[path] = null;
    List<_FilterPath> list = _getGetFilter(path);
    list.removeWhere((tmp) {
      if (tmp.action == null ||
          (tmp.observer != null && tmp.observer.isDisposed)) {
        return true;
      }
      if (isNotEmpty(region) && region != tmp.region) return false;
      TValue source = value;
      _processingCache[path] = null;
      value = tmp.action(value);
      if (source == value &&
          _processingCache.containsKey(path) &&
          _processingCache[path] != null) {
        value = _processingCache[path];
      }
      return false;
    });
    _processingCache.remove(path);
    return value;
  }

  /// Apply a set filter for a specific path.
  ///
  /// By specifying a region, you can apply a filter that is limited to the region.
  ///
  /// [path]: The path to apply the filter to.
  /// [value]: Data to filter.
  /// [region]: Region to apply the filter to.
  static TValue applySetFilter<TValue>(String path, TValue value,
      {String region}) {
    if (isEmpty(path)) return value;
    _processingCache[path] = null;
    List<_FilterPath> list = _getSetFilter(path);
    list.removeWhere((tmp) {
      if (tmp.action == null ||
          (tmp.observer != null && tmp.observer.isDisposed)) {
        return true;
      }
      if (isNotEmpty(region) && region != tmp.region) return false;
      TValue source = value;
      _processingCache[path] = null;
      value = tmp.action(value);
      if (source == value &&
          _processingCache.containsKey(path) &&
          _processingCache[path] != null) {
        value = _processingCache[path];
      }
      return false;
    });
    _processingCache.remove(path);
    return value;
  }

  /// Inserts GetFilter into the specified path.
  ///
  /// You can specify the execution order.
  ///
  /// By specifying [observer], it is possible to monitor only while the object exists.
  ///
  /// [path]: The path to filter.
  /// [filter]: Content to filter.
  /// [region]: Filter region.
  /// [order]: Filter execution order, smaller is faster.
  /// [observer]: Monitoring object. If this is deleted,
  /// the filter will be deleted automatically.
  static void insertGetFilter(String path, dynamic filter(dynamic value),
      {String region, int order = 0, Observer observer}) {
    if (isEmpty(path) || filter == null) return;
    int hash = filter.hashCode;
    if (_containsOnGetFilter(path, hash, region)) return;
    int position = 0;
    List<_FilterPath> list = _getGetFilter(path);
    for (int i = 0; i < list.length; i++) {
      if (list[i].order < order) break;
      position = i;
    }
    Log.ast("Adding to PathFilter: %s at %s", [path, position]);
    list.insert(
        position, _FilterPath(path, region, hash, filter, order, observer));
  }

  /// Removes a filter from the specified path.
  ///
  /// [path]: The path to delete.
  /// [filter]: The filter to delete. Delete only matches.
  /// [region]: Filter region.
  static void removeGetFilter(String path, dynamic filter(dynamic value),
      {String region}) {
    if (isEmpty(path) || filter == null) return;
    int hash = filter.hashCode;
    List<_FilterPath> list = _getGetFilter(path);
    for (int i = list.length - 1; i >= 0; i--) {
      _FilterPath tmp = list[i];
      if (path != tmp.path || hash != tmp.hash || region != tmp.region)
        continue;
      list.removeAt(i);
    }
  }

  /// Inserts SetFilter into the specified path.
  ///
  /// You can specify the execution order.
  ///
  /// By specifying [observer], it is possible to monitor only while the object exists.
  ///
  /// [path]: The path to filter.
  /// [filter]: Content to filter.
  /// [region]: Filter region.
  /// [order]: Filter execution order, smaller is faster.
  /// [observer]: Monitoring object. If this is deleted,
  /// the filter will be deleted automatically
  static void insertSetFilter(String path, dynamic filter(dynamic value),
      {String region, int order = 0, Observer observer}) {
    if (isEmpty(path) || filter == null) return;
    int hash = filter.hashCode;
    if (_containsOnSetFilter(path, hash, region)) return;
    int position = 0;
    List<_FilterPath> list = _getSetFilter(path);
    for (int i = 0; i < list.length; i++) {
      if (list[i].order < order) break;
      position = i;
    }
    Log.ast("Adding to PathFilter: %s at %s", [path, position]);
    list.insert(
        position, _FilterPath(path, region, hash, filter, order, observer));
  }

  /// Removes a filter from the specified path.
  ///
  /// [path]: The path to delete.
  /// [filter]: The filter to delete. Delete only matches.
  /// [region]: Filter region.
  static void removeSetFilter(String path, dynamic filter(dynamic value),
      {String region}) {
    if (isEmpty(path) || filter == null) return;
    int hash = filter.hashCode;
    List<_FilterPath> list = _getSetFilter(path);
    for (int i = list.length - 1; i >= 0; i--) {
      _FilterPath tmp = list[i];
      if (path != tmp.path || hash != tmp.hash || region != tmp.region)
        continue;
      list.removeAt(i);
    }
  }

  static List<_FilterPath> _getGetFilter(String path) {
    if (_onGetFilter.containsKey(path)) return _onGetFilter[path];
    return _onGetFilter[path] = ListPool.get();
  }

  static List<_FilterPath> _getSetFilter(String path) {
    if (_onSetFilter.containsKey(path)) return _onSetFilter[path];
    return _onSetFilter[path] = ListPool.get();
  }

  static bool _containsOnGetFilter(String path, int hash, String region) {
    if (isEmpty(path)) return false;
    List<_FilterPath> list = _getGetFilter(path);
    for (_FilterPath tmp in list) {
      if (tmp.path != path || hash != tmp.hash || region != tmp.region)
        continue;
      return true;
    }
    return false;
  }

  static bool _containsOnSetFilter(String path, int hash, String region) {
    if (isEmpty(path)) return false;
    List<_FilterPath> list = _getSetFilter(path);
    for (_FilterPath tmp in list) {
      if (tmp.path != path || hash != tmp.hash || region != tmp.region)
        continue;
      return true;
    }
    return false;
  }

  /// Clear all filters.
  static void clear() {
    _onGetFilter.clear();
    _onSetFilter.clear();
    _processingCache.clear();
  }
}

/// Path filter extension methods
extension PathFilterExtension<T extends IPath> on T {
  /// Inserts GetFilter into the specified path.
  ///
  /// You can specify the execution order.
  ///
  /// By specifying [observer], it is possible to monitor only while the object exists.
  ///
  /// [filter]: Content to filter.
  /// [region]: Filter region.
  /// [order]: Filter execution order, smaller is faster.
  /// [observer]: Monitoring object. If this is deleted,
  /// the filter will be deleted automatically.
  T insertGetFilter(dynamic filter(dynamic value),
      {String region, int order = 0, Observer observer}) {
    PathFilter.insertGetFilter(this.path, filter,
        region: region, order: order, observer: observer);
    return this;
  }

  /// Removes a filter from the specified path.
  ///
  /// [filter]: The filter to delete. Delete only matches.
  /// [region]: Filter region.
  T removeGetFilter(dynamic filter(dynamic value), {String region}) {
    PathFilter.removeGetFilter(this.path, filter, region: region);
    return this;
  }

  /// Inserts SetFilter into the specified path.
  ///
  /// You can specify the execution order.
  ///
  /// By specifying [observer], it is possible to monitor only while the object exists.
  ///
  /// [path]: The path to filter.
  /// [filter]: Content to filter.
  /// [region]: Filter region.
  /// [order]: Filter execution order, smaller is faster.
  /// [observer]: Monitoring object. If this is deleted,
  /// the filter will be deleted automatically.
  T insertSetFilter(String path, dynamic filter(dynamic value),
      {String region, int order = 0, Observer observer}) {
    PathFilter.insertSetFilter(this.path, filter,
        region: region, order: order, observer: observer);
    return this;
  }

  /// Removes a filter from the specified path.
  ///
  /// [path]: The path to delete.
  /// [filter]: The filter to delete. Delete only matches.
  /// [region]: Filter region.
  T removeSetFilter(String path, dynamic filter(dynamic value),
      {String region}) {
    PathFilter.removeSetFilter(this.path, filter, region: region);
    return this;
  }
}

/// Path filter extension methods
extension PathFilterFutureExtension<T extends IPath> on Future<T> {
  /// Inserts GetFilter into the specified path.
  ///
  /// You can specify the execution order.
  ///
  /// By specifying [observer], it is possible to monitor only while the object exists.
  ///
  /// [filter]: Content to filter.
  /// [region]: Filter region.
  /// [order]: Filter execution order, smaller is faster.
  /// [observer]: Monitoring object. If this is deleted,
  /// the filter will be deleted automatically.
  Future<T> insertGetFilter(dynamic filter(dynamic value),
      {String region, int order = 0, Observer observer}) {
    return this.then((p) {
      if (p == null) return p;
      PathFilter.insertGetFilter(p.path, filter,
          region: region, order: order, observer: observer);
      return p;
    });
  }

  /// Removes a filter from the specified path.
  ///
  /// [filter]: The filter to delete. Delete only matches.
  /// [region]: Filter region.
  Future<T> removeGetFilter(dynamic filter(dynamic value), {String region}) {
    return this.then((p) {
      if (p == null) return p;
      PathFilter.removeGetFilter(p.path, filter, region: region);
      return p;
    });
  }

  /// Inserts SetFilter into the specified path.
  ///
  /// You can specify the execution order.
  ///
  /// By specifying [observer], it is possible to monitor only while the object exists.
  ///
  /// [path]: The path to filter.
  /// [filter]: Content to filter.
  /// [region]: Filter region.
  /// [order]: Filter execution order, smaller is faster.
  /// [observer]: Monitoring object. If this is deleted,
  /// the filter will be deleted automatically.
  Future<T> insertSetFilter(String path, dynamic filter(dynamic value),
      {String region, int order = 0, Observer observer}) {
    return this.then((p) {
      if (p == null) return p;
      PathFilter.insertSetFilter(p.path, filter,
          region: region, order: order, observer: observer);
      return p;
    });
  }

  /// Removes a filter from the specified path.
  ///
  /// [path]: The path to delete.
  /// [filter]: The filter to delete. Delete only matches.
  /// [region]: Filter region.
  Future<T> removeSetFilter(String path, dynamic filter(dynamic value),
      {String region}) {
    return this.then((p) {
      if (p == null) return p;
      PathFilter.removeSetFilter(p.path, filter, region: region);
      return p;
    });
  }
}

class _FilterPath {
  String path;
  String region;
  int hash;
  dynamic Function(dynamic value) action;
  int order;
  Observer observer;
  _FilterPath(String path, String reegion, int hash,
      dynamic action(dynamic value), int order, Observer observer) {
    this.path = path;
    this.region = region;
    this.hash = hash;
    this.action = action;
    this.order = order;
    this.observer = observer;
  }
}
