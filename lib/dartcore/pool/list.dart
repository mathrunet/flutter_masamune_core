part of masamune.dartcore;

/// List object pool.
///
/// Usually used from pool.
///
/// When finished using, execute the [release()] method and return the object to the pool.
///
/// ```
/// List<String> list = ListPool.get();
/// ...
/// list.release();
/// ```
extension ListPool<T extends Object> on List<T> {
  /// Get a list from the object pool.
  ///
  /// If not, a new object will be created.
  ///
  /// When you have finished using it, return it to the pool with the [release()] method.
  ///
  /// [defaultValue]: Elements to put in advance when acquiring objects
  static List<TValue> get<TValue extends Object>([List<TValue> defaultValue]) {
    List<TValue> tmp = _ListPool<TValue>().get();
    if (defaultValue != null) tmp.addAll(defaultValue);
    return tmp;
  }

  /// Return the object to the pool.
  void release() => _ListPool<T>().release(this);
}

class _ListPool<T extends Object> extends ObjectPool<List<T>> {
  static Map<Type, _ListPool> _pools = Map<Type, _ListPool>();
  factory _ListPool() {
    if (!_pools.containsKey(T)) _pools[T] = _ListPool<T>._();
    return _pools[T];
  }
  _ListPool._() : super(() => List<T>(), onRelease: (r) => r.clear());
}
