part of masamune.path;

/// Listener to listen to collection counts and
/// reflect them in a particular field.
///
///
class CountListener {
  static Map<String, Map<String, _CountListenerPath>> _listener = MapPool.get();
  static Map<String, Map<String, void Function(IPath path)>> _callback =
      MapPool.get();

  /// Listen to the collection.
  ///
  /// The value increases when an element is added to the collection and
  /// decreases when the element is deleted.
  ///
  /// [path]: Collection path.
  /// [field]: Field pass of the counter.
  static void listen(String path, String field) {
    if (isEmpty(path) || isEmpty(field)) return;
    path = Paths.removeQuery(path);
    field = Paths.removeQuery(field);
    if (_listener.containsKey(path) && _listener[path].containsKey(field))
      return;
    IUnit tmp = PathMap.get<IUnit>(field);
    if (tmp == null) {
      if (!_callback.containsKey(path)) _callback[path] = MapPool.get();
      _callback[path][field] = (unit) {
        if (unit == null) return;
        if (unit is IUnit) {
          if (!_listener.containsKey(path)) _listener[path] = MapPool.get();
          _listener[path][field] = _CountListenerPath(path, unit);
        }
        if (_callback[path].containsKey(field))
          Future.delayed(Duration.zero,
              () => PathListener.unlisten(field, _callback[path][field]));
        _callback[path].remove(field);
      };
      PathListener.listen(field, _callback[path][field]);
    } else if (tmp is IUnit) {
      if (!_listener.containsKey(path)) _listener[path] = MapPool.get();
      _listener[path][field] = _CountListenerPath(path, tmp);
    }
  }

  /// Unlisten to the collection.
  ///
  /// [path]: Collection path.
  /// [field]: Field pass of the counter.
  static void unlisten(String path, String field) {
    if (isEmpty(path) || isEmpty(field)) return;
    if (_callback.containsKey(path) && _callback[path].containsKey(field)) {
      PathListener.unlisten(field, _callback[path][field]);
      _callback[path].remove(field);
    }
    if (_listener.containsKey(path) && _listener.containsKey(field)) {
      _listener[path].remove(field);
    }
  }

  static void _addCount(String path) => _invokeListener(path, 1);
  static void _subCount(String path) => _invokeListener(path, -1);
  static void _invokeListener(String path, int value) {
    if (isEmpty(path) || value == null) return;
    String parent = Paths.removeQuery(Paths.parent(path));
    if (isEmpty(parent) || !_listener.containsKey(parent)) return;
    for (MapEntry<String, _CountListenerPath> tmp
        in _listener[parent].entries) {
      if (isEmpty(tmp.key) || tmp.value == null) continue;
      if (tmp.value.unit == null) continue;
      if (tmp.value.unit.data is int) {
        tmp.value.unit.data = (tmp.value.unit.data as int) + value;
      } else if (tmp.value.unit.data is double) {
        tmp.value.unit.data =
            (tmp.value.unit.data as double) + value.toDouble();
      }
    }
  }
}

/// Collection listener extension methods
extension CollectionListenerExtension<T extends ICollection> on T {
  /// Listen to the collection.
  ///
  /// The value increases when an element is added to the collection and
  /// decreases when the element is deleted.
  ///
  /// [path]: Collection path.
  /// [field]: Field pass of the counter.
  T counting(String path) {
    if (isEmpty(path)) return this;
    if (this == null) return this;
    CountListener.listen(this.path, path);
    return this;
  }

  /// Unlisten to the collection.
  ///
  /// [path]: Collection path.
  /// [field]: Field pass of the counter.
  T uncounting(String path) {
    if (isEmpty(path)) return this;
    if (this == null) return this;
    CountListener.unlisten(this.path, path);
    return this;
  }
}

/// Collection listener extension methods
extension CollectionListenerFutureExtension<T extends ICollection>
    on Future<T> {
  /// Listen to the collection.
  ///
  /// The value increases when an element is added to the collection and
  /// decreases when the element is deleted.
  ///
  /// [path]: Collection path.
  /// [field]: Field pass of the counter.
  Future<T> counting(String path) {
    if (isEmpty(path)) return this;
    if (this == null) return this;
    return this.then((value) {
      CountListener.listen(value.path, path);
      return value;
    });
  }

  /// Unlisten to the collection.
  ///
  /// [path]: Collection path.
  /// [field]: Field pass of the counter.
  Future<T> uncounting(String path) {
    if (isEmpty(path)) return this;
    if (this == null) return this;
    return this.then((value) {
      CountListener.unlisten(value.path, path);
      return value;
    });
  }
}

class _CountListenerPath {
  final String path;
  final IUnit unit;
  const _CountListenerPath(this.path, this.unit);
}
