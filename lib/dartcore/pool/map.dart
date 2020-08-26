part of masamune.dartcore;

/// Map object pool
///
/// Usually used from pool.
///
/// When finished using, execute the [release()] method and return the object to the pool.
///
/// ```
/// Map<String,String> map = MapPool.get();
/// ...
/// map.release();
/// ```
extension MapPool<K extends Object, V extends Object> on Map<K, V> {
  /// Get a map from the object pool.
  ///
  /// If not, a new object will be created.
  ///
  /// When you have finished using it, return it to the pool with the [release()] method.
  ///
  /// [defaultValue]: Elements to put in advance when acquiring objects
  static Map<EK, EV> get<EK extends Object, EV extends Object>(
      [Map<EK, EV> defaultValue]) {
    Map<EK, EV> tmp = _MapPool<EK, EV>().get();
    if (defaultValue != null) tmp.addAll(defaultValue);
    return tmp;
  }

  /// Return the object to the pool.
  void release() => _MapPool<K, V>().release(this);
}

/// Extends the Map class.
extension MapExtension<K extends Object, V extends Object> on Map<K, V> {
  /// True if the map match.
  ///
  /// [other]: Map to compare.
  bool equals(Map<K, V> other) {
    if (this == other) return true;
    if (this.length != other.length) return false;
    for (MapEntry<K, V> tmp in this.entries) {
      if (!other.containsKey(tmp)) return false;
      if (other[tmp.key] != tmp.value) return false;
    }
    return true;
  }

  /// Method indexed forEach.
  ///
  /// The [index] starts at 0 and is incremented by 1.
  ///
  /// [function]: Action to be performed
  void forEachIndex(void function(K key, V value, int index)) {
    int i = 0;
    this.forEach((k, v) {
      function(k, v, i);
      i++;
    });
  }

  /// Create a map that extracts only the same values compared to a specific map.
  /// 
  /// [checkOnlyKey]: If True,
  /// returns the value contained in the given map if it has the same key.
  Map<K, V> duplicate(Map<K, V> map, {bool checkOnlyKey = false}) {
    if (map == null) return this;
    if (this == null || this.length <= 0) return map;
    Map<K, V> res = MapPool.get();
    for (MapEntry<K, V> tmp in map.entries) {
      if (checkOnlyKey) {
        if (this.containsKey(tmp.key)) res[tmp.key] = tmp.value;
      } else {
        if (this.containsKey(tmp.key) && tmp.value == this[tmp.key])
          res[tmp.key] = tmp.value;
      }
    }
    return res;
  }

  /// Convert it to a list through [callback].
  ///
  /// [callback]: Callback function.
  Iterable<T> toList<T extends Object>(T callback(K key, V value)) sync* {
    for (MapEntry<K, V> tmp in this.entries) yield callback(tmp.key, tmp.value);
  }
}

class _MapPool<K extends Object, V extends Object>
    extends ObjectPool<Map<K, V>> {
  static Map<Type, Map<Type, dynamic>> _pools = Map<Type, Map<Type, dynamic>>();
  factory _MapPool() {
    if (!_pools.containsKey(K)) _pools[K] = Map<Type, _MapPool>();
    if (!_pools[K].containsKey(V)) _pools[K][V] = _MapPool<K, V>._();
    return _pools[K][V];
  }
  _MapPool._() : super(() => Map<K, V>(), onRelease: (r) => r.clear());
}
