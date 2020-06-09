part of masamune.dartcore;

/// An abstract class for creating object pools.
///
/// Please inherit and use.
abstract class ObjectPool<T extends Object> {
  final Queue<T> _pool = Queue<T>();
  T Function() _onNew;
  void Function(T element) _onGet;
  void Function(T element) _onRelease;

  /// An abstract class for creating object pools.
  ///
  /// [onNew]: Callback when creating a new object.
  /// [onGet]: Callback when getting an object (including when creating a new one).
  /// [onRelease]: Callback when the object is destroyed (that is, when returning to the pool).
  ObjectPool(T onNew(), {void onGet(T element), void onRelease(T element)}) {
    this._onNew = onNew;
    this._onGet = onGet;
    this._onRelease = onRelease;
  }

  /// Get an object from the object pool.
  ///
  /// If there is no object in the pool, create a new one.
  T get() {
    T t;
    try {
      do {
        if (_pool.isEmpty) {
          t = this._onNew();
        } else {
          t = _pool.removeFirst();
        }
      } while (t == null);
    } catch (e) {
      t = this._onNew();
    }
    if (this._onGet != null) this._onGet(t);
    return t;
  }

  /// Return the object to the pool.
  ///
  /// [element]: Objects to return to the pool.
  void release(T element) {
    if (element == null) return;
    try {
      if (_pool.length > 0 && _pool.last == element) return;
      if (this._onRelease != null) this._onRelease(element);
      _pool.addLast(element);
    } catch (e) {
      Log.error(e.toString());
    }
  }
}
