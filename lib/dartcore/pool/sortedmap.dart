part of masamune.dartcore;

/// SortedMap object pool.
///
/// Usually used from pool.
///
/// When finished using, execute the [release()] method and return the object to the pool.
///
/// ```
/// SortedMap<String,String> map = SortedMapPool.get();
/// ...
/// map.release();
/// ```
extension SortedMapPool<K extends Object, V extends Object> on SortedMap<K, V> {
  /// Get a sortedmap from the object pool.
  ///
  /// If not, a new object will be created.
  ///
  /// When you have finished using it, return it to the pool with the [release()] method.
  ///
  /// [defaultValue]: Elements to put in advance when acquiring objects.
  static SortedMap<EK, EV> get<EK extends Object, EV extends Object>(
      [SortedMap<EK, EV> defaultValue]) {
    SortedMap<EK, EV> tmp = _SortedMapPool<EK, EV>().get();
    if (defaultValue != null) tmp.addAll(defaultValue);
    return tmp;
  }

  /// Return the object to the pool.
  void release() => _SortedMapPool<K, V>().release(this);
}

/// Extends the SortedMap class.
extension SortedMapExtension<K extends Object, V extends Object>
    on SortedMap<K, V> {
  /// Method indexed forEach
  /// The [index] starts at 0 and is incremented by 1
  ///
  /// [function]: Action to be performed
  void forEachIndex(void function(K key, V value, int index)) {
    int i = 0;
    this.forEach((k, v) {
      function(k, v, i);
      i++;
    });
  }
}

class _SortedMapPool<K extends Object, V extends Object>
    extends ObjectPool<SortedMap<K, V>> {
  static SortedMap<Type, SortedMap<Type, dynamic>> _pools =
      SortedMap<Type, SortedMap<Type, dynamic>>();
  factory _SortedMapPool() {
    if (!_pools.containsKey(K)) _pools[K] = SortedMap<Type, _SortedMapPool>();
    if (!_pools[K].containsKey(V)) _pools[K][V] = _SortedMapPool<K, V>._();
    return _pools[K][V];
  }
  _SortedMapPool._()
      : super(() => SortedMap<K, V>(), onRelease: (r) => r.clear());
}
