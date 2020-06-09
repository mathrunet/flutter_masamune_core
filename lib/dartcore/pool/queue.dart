part of masamune.dartcore;

/// Queue object pool.
///
/// Usually used from pool.
///
/// When finished using, execute the [release()] method and return the object to the pool.
///
/// ```
/// Queue<String> queue = QueuePool.get();
/// ...
/// queue.release();
/// ```
extension QueuePool<T extends Object> on Queue<T> {
  /// Get a queue from the object pool.
  ///
  /// If not, a new object will be created.
  ///
  /// When you have finished using it, return it to the pool with the [release()] method.
  ///
  /// [defaultValue]: Elements to put in advance when acquiring objects.
  static Queue<E> get<E extends Object>([Queue<E> defaultValue]) {
    Queue<E> tmp = _QueuePool<E>().get();
    if (defaultValue != null) tmp.addAll(defaultValue);
    return tmp;
  }

  /// Return the object to the pool.
  void release() => _QueuePool<T>().release(this);
}

class _QueuePool<T extends Object> extends ObjectPool<Queue<T>> {
  static Map<Type, _QueuePool> _pools = Map<Type, _QueuePool>();
  factory _QueuePool() {
    if (!_pools.containsKey(T)) _pools[T] = _QueuePool<T>._();
    return _pools[T];
  }
  _QueuePool._() : super(() => Queue<T>(), onRelease: (r) => r.clear());
}
