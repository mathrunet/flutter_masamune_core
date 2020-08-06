part of masamune.path;

class CountListener {
  static Map<String, Map<String, _CountListenerPath>> _listener = MapPool.get();
  static Map<String, Map<String, void Function(IPath path)>> _callback =
      MapPool.get();

  static void listen(String path, String target) {
    if (isEmpty(path) || isEmpty(target)) return;
    path = Paths.removeQuery(path);
    target = Paths.removeQuery(target);
    if (_listener.containsKey(path) && _listener[path].containsKey(target))
      return;
    IUnit tmp = PathMap.get<IUnit>(target);
    if (tmp == null) {
      if (!_callback.containsKey(path)) _callback[path] = MapPool.get();
      _callback[path][target] = (unit) {
        if (unit == null) return;
        if (unit is IUnit) {
          if (!_listener.containsKey(path)) _listener[path] = MapPool.get();
          _listener[path][target] = _CountListenerPath(path, unit);
        }
        if (_callback[path].containsKey(target))
          Future.delayed(Duration.zero,
              () => PathListener.unlisten(target, _callback[path][target]));
        _callback[path].remove(target);
      };
      PathListener.listen(target, _callback[path][target]);
    } else if (tmp is IUnit) {
      if (!_listener.containsKey(path)) _listener[path] = MapPool.get();
      _listener[path][target] = _CountListenerPath(path, tmp);
    }
  }

  static void unlisten(String path, String target) {
    if (isEmpty(path) || isEmpty(target)) return;
    if (_callback.containsKey(path) && _callback[path].containsKey(target)) {
      PathListener.unlisten(target, _callback[path][target]);
      _callback[path].remove(target);
    }
    if (_listener.containsKey(path) && _listener.containsKey(target)) {
      _listener[path].remove(target);
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

class _CountListenerPath {
  final String path;
  final IUnit unit;
  const _CountListenerPath(this.path, this.unit);
}
