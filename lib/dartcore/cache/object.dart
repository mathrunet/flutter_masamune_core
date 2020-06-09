part of masamune.dartcore;

/// Abstract class for creating an object cache.
///
/// You can save objects in key-value pairs.
///
/// Get the value with the get method.
///
/// Create a new object if not cached.
abstract class ObjectCache<K, V> {
  final Map<K, V> _cache = Map<K, V>();
  V Function(K key) _onNew;
  void Function(V element) _onGet;

  /// Abstract class for creating an object cache.
  ///
  /// You can save objects in key-value pairs.
  ///
  /// Get the value with the get method.
  ///
  /// Create a new object if not cached.
  ///
  /// [onNew]: Callback for new creation.
  /// [onGet]: Callback for object acquisition (including new creation).
  ObjectCache(V onNew(K key), {void onGet(V element)}) {
    this._onNew = onNew;
    this._onGet = onGet;
  }

  /// Get the object by specifying [key].
  ///
  /// If the object does not exist, it will be created.
  ///
  /// [key]: Key stored in cache
  V get(K key) {
    V t;
    try {
      Map<K, V> stack = _cache;
      if (stack.isEmpty ||
          !stack.containsKey(key) ||
          (t = stack[key]) == null) {
        t = this._onNew(key);
        stack[key] = t;
      }
      this._onGet(t);
    } catch (e) {
      t = this._onNew(key);
    }
    return t;
  }
}
