part of masamune.path;

/// Manages pal system paths.
///
/// Map all non-temporary path data to avoid duplication.
///
/// Parental and child relationships can be maintained, grouped, and collectively deleted by type.
///
/// ```
/// PathMap.get( "data/asset" );
/// ```
class PathMap {
  static Map<String, IPath> _data = MapPool.get();
  static Map<String, String> _link = MapPool.get();

  /// Gets the object at the specified path.
  ///
  /// If no path is specified,
  /// search for a matching type from all paths and return the first object that matches.
  ///
  /// [path]: The path to get.
  static T get<T extends Object>([String path]) {
    path = path?.applyTags();
    if (isEmpty(path)) {
      for (MapEntry<String, IPath> tmp in _data.entries) {
        if (tmp.value == null) continue;
        if (!(tmp.value is T)) continue;
        return tmp.value as T;
      }
      return null;
    }
    if (_data.containsKey(path)) {
      IPath tmp = _data[path];
      if (tmp is IUnit && tmp.data is T) return tmp.data;
      if (!(tmp is T)) {
        if (tmp != null) {
          Log.ast("The object type is different: %s and %s with %s",
              [tmp.runtimeType, T, path]);
        }
        return null;
      }
      return tmp as T;
    }
    if (_link.containsKey(path)) return get<T>(_link[path]);
    return null;
  }

  /// Gets all path objects of the matching type from the pathmap.
  static List<T> getAll<T extends IPath>() {
    List<T> list = ListPool.get();
    for (MapEntry<String, IPath> tmp in _data.entries) {
      if (tmp.value == null) continue;
      if (!(tmp.value is T)) continue;
      list.add(tmp.value as T);
    }
    return list;
  }

  /// Check if the path exists in the pathmap.
  ///
  /// True if the path exists in the pathmap.
  ///
  /// [path]: The path to check.
  static bool containsKey(String path) {
    if (isEmpty(path)) return false;
    if (_link.containsKey(path)) return true;
    return _data.containsKey(path);
  }

  /// Check if the path object exists in the pathmap.
  ///
  /// True if the path object exists in the pathmap.
  ///
  /// [value]: The path object to check.
  static bool containsValue(IPath value) {
    if (value == null) return false;
    return _data.containsValue(value);
  }

  /// Add a new path object to the pathmap.
  ///
  /// Temporary data or duplicate additions are not allowed.
  ///
  /// Also, if there is a parent-child relationship with the existing path,
  /// it will be adjusted automatically.
  ///
  /// [data]: The path object to add.
  static void add(IPath data) {
    assert(data != null);
    if (data == null) {
      Log.error("Adding data is invalid.");
      return;
    }
    if (data.isTemporary) {
      Log.warning(
          "Can't add the temporary data. please check the IsTemporary value");
      return;
    }
    String path = data.path;
    Log.ast("Adding to PathMap: %s", [path]);
    if (PathMap.containsKey(path)) {
      Log.warning("The data path is already exist: %s and %s",
          [data.runtimeType, path]);
      return;
    }
    _data[path] = data;
    if (data is IChild) {
      for (MapEntry<String, IPath> tmp in _data.entries) {
        if (!(tmp.value is IParent)) continue;
        if (Paths.parent(data.path) != tmp.value.path) continue;
        tmp.value.asType<IParent>()._addChildInernal(data);
      }
    }
  }

  /// Removes an object from the pathmap given its path.
  ///
  /// [path]: The path to delete.
  static void removePath(String path) {
    if (isEmpty(path)) return;
    _link.remove(path);
    if (!_data.containsKey(path)) return;
    IPath data = _data[path];
    if (data == null || data.group < 0 || !data.isDisposable) return;
    _removeInternal(data);
    data.dispose();
    _data.remove(path);
  }

  /// Removes all corresponding path objects from the specified path list.
  ///
  /// [paths]: The path list to delete.
  static void removeAllPath(Iterable<String> paths) {
    if (paths == null) return;
    for (String key in paths) removePath(key);
  }

  /// Removes an object from the pathmap given its group number.
  ///
  /// [group]: The group number to delete.
  static void removeGroup(int group) {
    if (group < 0) return;
    _data.removeWhere((key, value) {
      if (value == null || value.group != group || !value.isDisposable)
        return false;
      _removeInternal(value);
      value.dispose();
      return true;
    });
  }

  /// Removes all corresponding path objects from the specified group list.
  ///
  /// [groups]: The group list to delete.
  static void removeAllGroup(Iterable<int> groups) {
    if (groups == null) return;
    for (int key in groups) removeGroup(key);
  }

  /// Deletes the specified path object.
  ///
  /// [path]: The path object to delete.
  static void remove(IPath path) => removePath(path?.path);
  static void _removeInternal(IPath path) {
    if (!(path is IChild)) return;
    for (MapEntry<String, IPath> data in _data.entries) {
      if (!(data.value is IParent)) continue;
      if (Paths.parent(path.path) != data.key) continue;
      (data.value as IParent)._removeChildInternal(path);
    }
  }

  /// Removes an object from the pathmap given its type.
  ///
  /// [group]: The type to delete.
  static void removeType(Type type) {
    if (type == null) return;
    _data.removeWhere((key, value) {
      if (value == null ||
          value.runtimeType != type ||
          value.group < 0 ||
          !value.isDisposable) return false;
      _removeInternal(value);
      value.dispose();
      return true;
    });
  }

  /// Removes all corresponding path objects from the specified type list.
  ///
  /// [groups]: The type list to delete.
  static void removeAllType(Iterable<Type> types) {
    if (types == null) return;
    for (Type key in types) removeType(key);
  }

  /// Deletes path objects that match the specified conditions.
  ///
  /// [predicate]: The condition to delete. If [predicate] is True, delete the object.
  static void removeWhere(bool predicate(String path, IPath item)) {
    if (predicate == null) return;
    _data.removeWhere((key, value) {
      if (value == null ||
          value.group < 0 ||
          !value.isDisposable ||
          !predicate(key, value)) return false;
      _removeInternal(value);
      value.dispose();
      return true;
    });
  }

  /// Callback event when application pauses.
  ///
  /// [pause]: True when application is paused, False when returning from pause.
  static void onApplicationPause(bool pause) {
    for (IPath data in _data.values) {
      if (data == null) continue;
      data.onApplicationPause(pause);
    }
  }

  /// Callback event when application quit.
  static void onApplicationQuit() {
    for (IPath data in _data.values) {
      if (data == null) continue;
      data.onApplicationQuit();
    }
  }

  /// Clear all pathmaps.
  static void clear() {
    _data.clear();
  }

  /// Link with another path.
  ///
  /// You can access the same object even if you access the linked path.
  ///
  /// If the path of the actual object exists, it takes precedence.
  ///
  /// If the link destination is a link, it will be overwritten.
  ///
  /// [fromPath]: Referrer path.
  /// [toPath]: Referenced path.
  static void link(String fromPath, String toPath) {
    if (isEmpty(fromPath) || isEmpty(toPath)) {
      Log.error("The path is invalid.");
      return;
    }
    _link[toPath] = fromPath;
    Log.ast("Link from %s to %s", [fromPath, toPath]);
  }
}
