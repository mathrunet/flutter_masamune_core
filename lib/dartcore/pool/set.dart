part of masamune.dartcore;

/// Sets object pool.
///
/// Usually used from pool.
///
/// When finished using, execute the [release()] method and return the object to the pool.
///
/// ```
/// Set<String> sets = SetPool.get();
/// ...
/// sets.release();
/// ```
extension SetPool<T extends Object> on Set<T> {
  /// Get a sets from the object pool.
  ///
  /// If not, a new object will be created.
  ///
  /// When you have finished using it, return it to the pool with the [release()] method.
  ///
  /// [defaultValue]: Elements to put in advance when acquiring objects.
  static Set<E> get<E extends Object>([Set<E> defaultValue]) {
    Set<E> tmp = _SetPool<E>().get();
    if (defaultValue != null) tmp.addAll(defaultValue);
    return tmp;
  }

  /// Return the object to the pool.
  void release() => _SetPool<T>().release(this);
}

class _SetPool<T extends Object> extends ObjectPool<Set<T>> {
  static Map<Type, _SetPool> _pools = Map<Type, _SetPool>();
  factory _SetPool() {
    if (!_pools.containsKey(T)) _pools[T] = _SetPool<T>._();
    return _pools[T];
  }
  _SetPool._() : super(() => Set<T>(), onRelease: (r) => r.clear());
}
