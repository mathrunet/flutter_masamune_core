part of masamune.path;

/// Monitor filter changes.
///
/// Specify the monitoring target path in [listen()] and
/// execute the process when there is any change.
///
/// ```
/// PathListener.listen( "data/user", ( path ) => Log.msg( "Updated" ) );
/// ```
class PathListener {
  static Timer _timer;
  static Map<String, Map<int, _ListenerPath>> _listener = MapPool.get();
  static List _updateStack = ListPool.get();
  static void _startUpdate() {
    if (_timer != null) return;
    _timer = Timer.periodic(Config.frameTime, (timer) {
      Set<IPath> cache = SetPool.get();
      while (_updateStack.length > 0) {
        IPath path = _updateStack.removeLast();
        if (path == null ||
            path.isTemporary ||
            isEmpty(path.path) ||
            cache.contains(path)) continue;
        cache.add(path);
        _invokeListener(path.path);
      }
      cache.release();
    });
  }

  /// Start monitoring for path changes.
  ///
  /// If there is a change in [path], [onUpdate] is called.
  ///
  /// If [observer] is set, monitoring will automatically end when [observer] is deleted.
  ///
  /// [path]: Path to monitor.
  /// [onUpdate]: Callback executed when [path] changes.
  /// [observer]: Monitoring object. If this is deleted, monitoring will automatically end.
  static void watch<T extends IPath>(String path, void onUpdate(T path),
          {Observer observer}) =>
      listen<T>(path, onUpdate, observer: observer);

  /// Start monitoring for path changes.
  ///
  /// If there is a change in [path], [onUpdate] is called.
  ///
  /// If [observer] is set, monitoring will automatically end when [observer] is deleted.
  ///
  /// [path]: Path to monitor.
  /// [onUpdate]: Callback executed when [path] changes.
  /// [observer]: Monitoring object. If this is deleted, monitoring will automatically end.
  static void listen<T extends IPath>(String path, void onUpdate(T path),
      {Observer observer}) {
    if (isEmpty(path) || onUpdate == null) return;
    _startUpdate();
    Type type = T;
    int hash = onUpdate.hashCode;
    if (_containsListener(path, hash)) return;
    Log.ast("Adding to PathListener: %s and %s", [path, T]);
    Map<int, _ListenerPath> map = _getListeners(path);
    map[hash] =
        _ListenerPath(path, type, hash, (r) => onUpdate(r as T), observer);
  }

  /// Stop monitoring a specific path.
  ///
  /// [path]: Path to monitor.
  /// [onUpdate]: Processing to stop monitoring. Exit only matches.
  static void unwatch<T extends IPath>(String path, void onUpdate(T path)) =>
      unlisten<T>(path, onUpdate);

  /// Stop monitoring a specific path.
  ///
  /// [path]: Path to monitor.
  /// [onUpdate]: Processing to stop monitoring. Exit only matches.
  static void unlisten<T extends IPath>(String path, void onUpdate(T path)) {
    if (isEmpty(path) || onUpdate == null) return;
    int hash = onUpdate.hashCode;
    Map<int, _ListenerPath> map = _getListeners(path);
    Log.ast("Removing from PathListener: %s and %s", [path, T]);
    map.remove(hash);
  }

  static void _updateNotify(IPath path) {
    Log.ast("Enqueue to invoking action: %s", [path.path]);
    _updateStack.add(path);
  }

  static void _invokeListener(String path) {
    if (isEmpty(path)) return;
    Map<int, _ListenerPath> map = _getListeners(path);
    map.removeWhere((hash, tmp) {
      if (tmp.action == null ||
          (tmp.observer != null && tmp.observer.isDisposed)) {
        return true;
      }
      IPath val = PathMap.get(path);
      tmp.action(val);
      return false;
    });
  }

  static Map<int, _ListenerPath> _getListeners(String path) {
    if (_listener.containsKey(path)) return _listener[path];
    return _listener[path] = MapPool.get();
  }

  static bool _containsListener(String path, int hash) {
    Map<int, _ListenerPath> tmp = _getListeners(path);
    return tmp.containsKey(hash);
  }

  /// Clear all listeners
  static void clear() {
    _listener.clear();
    _updateStack.clear();
  }
}

/// Path listener extension methods
extension PathListenerExtension<T extends IPath> on T {
  /// Start monitoring for path changes.
  ///
  /// If there is a change in [path], [onUpdate] is called.
  ///
  /// If [observer] is set, monitoring will automatically end when [observer] is deleted.
  ///
  /// [onUpdate]: Callback executed when [path] changes.
  /// [observer]: Monitoring object. If this is deleted, monitoring will automatically end.
  T watch(void onUpdate(T path), {Observer observer}) =>
      listen(onUpdate, observer: observer);

  /// Start monitoring for path changes.
  ///
  /// If there is a change in [path], [onUpdate] is called.
  ///
  /// If [observer] is set, monitoring will automatically end when [observer] is deleted.
  ///
  /// [onUpdate]: Callback executed when [path] changes.
  /// [observer]: Monitoring object. If this is deleted, monitoring will automatically end.
  T listen(void onUpdate(T path), {Observer observer}) {
    if (this == null) return this;
    PathListener.listen(this.path, onUpdate, observer: observer);
    return this;
  }

  /// Stop monitoring a specific path.
  ///
  /// [onUpdate]: Processing to stop monitoring. Exit only matches.
  T unwatch(void onUpdate(T path)) => unlisten(onUpdate);

  /// Stop monitoring a specific path.
  ///
  /// [onUpdate]: Processing to stop monitoring. Exit only matches.
  T unlisten(void onUpdate(T path)) {
    if (this == null) return this;
    PathListener.unlisten(this.path, onUpdate);
    return this;
  }
}

/// Path listener extension methods
extension PathListenerFutureExtension<T extends IPath> on Future<T> {
  /// Start monitoring for path changes.
  ///
  /// If there is a change in [path], [onUpdate] is called.
  ///
  /// If [observer] is set, monitoring will automatically end when [observer] is deleted.
  ///
  /// [onUpdate]: Callback executed when [path] changes.
  /// [observer]: Monitoring object. If this is deleted, monitoring will automatically end.
  Future<T> watch(void onUpdate(T path), {Observer observer}) =>
      listen(onUpdate, observer: observer);

  /// Start monitoring for path changes.
  ///
  /// If there is a change in [path], [onUpdate] is called.
  ///
  /// If [observer] is set, monitoring will automatically end when [observer] is deleted.
  ///
  /// [onUpdate]: Callback executed when [path] changes.
  /// [observer]: Monitoring object. If this is deleted, monitoring will automatically end.
  Future<T> listen(void onUpdate(T path), {Observer observer}) {
    return this.then((p) {
      if (p == null) return p;
      PathListener.listen(p.path, onUpdate, observer: observer);
      return p;
    });
  }

  /// Stop monitoring a specific path.
  ///
  /// [onUpdate]: Processing to stop monitoring. Exit only matches.
  Future<T> unwatch(void onUpdate(T path)) => unlisten(onUpdate);

  /// Stop monitoring a specific path.
  ///
  /// [onUpdate]: Processing to stop monitoring. Exit only matches.
  Future<T> unlisten(void onUpdate(T path)) {
    return this.then((p) {
      if (p == null) return p;
      PathListener.unlisten(p.path, onUpdate);
      return p;
    });
  }
}

class _ListenerPath {
  final String path;
  final Type type;
  final int hash;
  final void Function(IPath path) action;
  final Observer observer;
  const _ListenerPath(String path, Type type, int hash,
      void Function(IPath path) action, Observer observer)
      : this.path = path,
        this.type = type,
        this.hash = hash,
        this.action = action,
        this.observer = observer;
}
