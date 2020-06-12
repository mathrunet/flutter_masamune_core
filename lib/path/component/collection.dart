part of masamune.path;

/// Abstract class that can create collections.
///
/// Keys are not saved, but the order is preserved.
///
/// Collections can contain IChild, documents and units.
///
/// Please inherit and use.
abstract class Collection<TChild extends IChild>
    with IterableMixin<TChild>
    implements IPath, ICollection<TChild>, IParent {
  /// Get the data.
  ///
  /// Protected data.
  @protected
  SortedMap<String, TChild> get data => this._data;
  SortedMap<String, TChild> _data = SortedMapPool.get();

  /// Set the data.
  ///
  /// Protected data.
  ///
  /// [children]: List of data.
  @protected
  void set(Iterable<TChild> children) =>
      children?.forEach((child) => this.setInternal(child));

  /// Abstract class that can create collections.
  ///
  /// Keys are not saved, but the order is preserved.
  ///
  /// Collections can contain IChild, documents and units.
  ///
  /// [path]: Collection pathpath.
  /// [children]: Initial collection data, using TChild array.
  /// [isTemporary]: True if it is temporary data.
  /// [group]: Unit group (0 or more).
  /// [order]: Unit order.
  @protected
  Collection(String path,
      {Iterable<TChild> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10}) {
    if (isEmpty(path)) path = Texts.uuid;
    this._path = Path(path);
    this._order = order;
    this._isTemporary = isTemporary;
    if (group < -1) group = -1;
    this._group = group;
    children?.forEach((value) => this.setInternal(value));
    if (!this.isTemporary) PathMap.add(this);
  }

  /// Processing to set a value.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: Value to set.
  @protected
  void setInternal(TChild value) {
    if (value == null) return;
    String key = value.id;
    if (isEmpty(key)) key = Texts.uuid;
    TChild exist = this.data.firstWhere(
        (k, v) => v.path == value.path || v == value,
        orElse: () => null);
    if (exist != null) {
      if (exist != value) value.copyTo(exist);
    } else {
      Path path = this.rawPath.clone();
      path.path = Paths.child(this.rawPath.path, key);
      TChild saved = PathMap.get<TChild>(path.path);
      if (saved != null) {
        value.copyTo(saved);
        value = saved;
      } else {
        value = path.url == value.path
            ? value
            : value.clone(path: path.url, isTemporary: false);
      }
      value._addParentInternal(this);
      this.data[key] = value;
    }
    this.notifyUpdate(value.updatedTime);
  }

  /// Processing to delete values.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: The value to remove.
  @protected
  void unsetInternal(TChild child) {
    if (child == null) return;
    if (!this.data.containsKey(child.id)) return;
    child?._removeParentInternal(this);
    child?.dispose();
    this.data.remove(child.id);
    this.notifyUpdate();
  }

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary);

  void _addChildInernal(IChild child) {
    if (!(child is TChild)) return;
    if (isEmpty(child.path) || Paths.parent(child.path) != this.path) return;
    TChild data = this.data.firstWhere((k, v) => v.id == child.id || v == child,
        orElse: () => null);
    if (data != null) return;
    this.setInternal(child);
    Log.ast("Adding child: %s(%s)", [child.path, child]);
  }

  void _removeChildInternal(IChild child) {
    if (!(child is TChild)) return;
    if (isEmpty(child.path) || Paths.parent(child.path) != this.path) return;
    this.unsetInternal(child);
    Log.ast("Removing child: %s(%s)", [child.path, child]);
  }

  /// True if the object is temporary data.
  bool get isTemporary => this.protocol == Protocol.tmp || this._isTemporary;
  bool _isTemporary = false;

  /// Register the temporary data in the path map.
  ///
  /// Not registered if the protocol is temporary.
  @protected
  void registerUntemporary() {
    if (!this._isTemporary) return;
    this._isTemporary = false;
    if (!this.isTemporary) PathMap.add(this);
  }

  /// Get the protocol of the path.
  String get protocol;

  /// Get the path.
  String get path => this._path.url;

  /// Get ID.
  ///
  /// Usually the string of the child of the path.
  String get id {
    if (isEmpty(this._path?.file)) return Const.empty;
    return this._path.file;
  }

  /// Get the path extension.
  String get extension {
    if (isEmpty(this._path?.extension)) return Const.empty;
    return this._path.extension;
  }

  /// Get the path structure.
  Path get rawPath => this._path;
  Path _path;

  /// Get number of documents.
  int get length => this.data.length;

  /// Iterator.
  ///
  /// Can be turned with for.
  Iterator<TChild> get iterator => this.data.values.iterator;

  /// Checks if [child] is included.
  ///
  /// True if [child] is included.
  ///
  /// [child]: The object to check.
  bool contains(Object child) {
    if (child == null) return false;
    return this.data.containsValue(child);
  }

  /// Check if there is an element with [id].
  ///
  /// True if [id] is present.
  ///
  /// [id]: ID to check.
  bool containsID(String id) {
    if (isEmpty(id)) return false;
    return this.data.containsKey(id);
  }

  /// Check if there is an element with [path].
  ///
  /// True if [path] is present.
  ///
  /// [path]: ID to check.
  bool containsPath(String path) {
    if (isEmpty(path)) return false;
    for (MapEntry<String, TChild> tmp in this.data.entries) {
      if (tmp == null || path != tmp.value.path) continue;
      return true;
    }
    return false;
  }

  /// Iterates the contents of the document using [TChild].
  ///
  /// [function]: Iterative processing of [TChild].
  void forEach(void function(TChild value)) =>
      this.data.values.forEach(function);

  /// Add a new value.
  ///
  /// [value]: Value to add.
  Collection<TChild> operator +(TChild value) {
    this.add(value);
    return this;
  }

  /// Remove a value.
  ///
  /// [value]: Value to remove.
  Collection<TChild> operator -(TChild value) {
    this.remove(value);
    return this;
  }

  /// Add data to the document.
  ///
  /// [child]: Data to add.
  void add(TChild child) {
    assert(child != null);
    if (child == null) {
      Log.error("Add data is null");
      return;
    }
    if (this.isLock) {
      Log.warning("Data modification is prohibited.");
      return;
    }
    this.setInternal(child);
  }

  /// Add data to the document.
  ///
  /// [children]: Data to add.
  void addAll(Iterable<TChild> children) {
    assert(children != null);
    if (children == null) {
      Log.error("Add data is null");
      return;
    }
    if (this.isLock) {
      Log.warning("Data modification is prohibited.");
      return;
    }
    for (TChild child in children) {
      if (child == null) continue;
      this.setInternal(child);
    }
  }

  /// Remove data from collection.
  ///
  /// [child]: Data to delete.
  void remove(TChild child) {
    assert(child != null);
    if (child == null) return;
    if (this.isLock) {
      Log.warning("Data modification is prohibited.");
      return;
    }
    TChild data = this.data.firstWhere(
        (k, v) => v.path == child.path || v == child,
        orElse: () => null);
    if (data == null) return;
    this.unsetInternal(data);
    this.notifyUpdate();
  }

  /// Remove data at index.
  ///
  /// [index]: The index to delete.
  void removeAt(int index) {
    TChild child = this.data[index];
    if (child == null) return;
    this.unsetInternal(child);
    this.notifyUpdate();
  }

  /// Specify the key and delete.
  ///
  ///[key]: Key to delete.
  void removeBy(String key) {
    TChild child = this.data[key];
    if (child == null) return;
    this.unsetInternal(child);
    this.notifyUpdate();
  }

  /// Remove data from collection.
  ///
  /// [children]: Data to delete.
  void removeAll(Iterable<TChild> children) {
    assert(children != null);
    if (children == null) return;
    if (this.isLock) {
      Log.warning("Data modification is prohibited.");
      return;
    }
    for (int i = this.data.length - 1; i >= 0; i--) {
      TChild data = this.data[i];
      if (data == null || !children.contains(data)) continue;
      this.unsetInternal(data);
    }
    this.notifyUpdate();
  }

  /// Deletes the element conditionally.
  ///
  /// [predicate]: Csonditions. If True, delete.
  void removeWhere(bool predicate(TChild child)) {
    if (predicate == null) return;
    List<MapEntry<String, TChild>> remove =
        this.data.where((key, value) => predicate(value)).toList();
    if (remove == null || remove.length <= 0) return;
    for (MapEntry<String, TChild> tmp in remove) {
      if (tmp.value == null) continue;
      this.data.remove(tmp.key);
    }
    this.notifyUpdate();
  }

  /// Remove all data from the document.
  void clear() {
    if (this.isLock) {
      Log.warning("Data modification is prohibited.");
      return;
    }
    for (TChild child in this.data.values.toList()) this.unsetInternal(child);
    this.data.clear();
    this.notifyUpdate();
  }

  /// Debug output The debug output differs depending on the object.
  ///
  /// [value]: The object to enter.
  T debug<T extends IDebuggable>([Object object]) {
    Log.msg("Collection[%s][%s]\n%s",
        [this.runtimeType, this.path, Json.encode(this)]);
    return this as T;
  }

  /// Interface for use with Json serialization.
  Map<String, dynamic> toJson() {
    return this.data.map((key, value) {
      if (value is IUnit) return MapEntry(key, value.data);
      return MapEntry(key, value);
    });
  }

  /// Get the data.
  ///
  /// [key]: Key for retrieving data.
  TChild operator [](Object key) {
    if (key is int) {
      if (key < 0 || this.data.length <= key) return null;
      return this.data[key];
    } else if (key is String) {
      if (isEmpty(key) || !this.data.containsKey(key)) return null;
      return this.data[key];
    }
    return null;
  }

  /// Get group number.
  int get group => this._group;
  int _group = 0;

  /// Get the order, the lower the number, the faster.
  int get order => this._order;
  int _order = 0;

  /// True if object is locked.
  bool get isLock => this._isLock;
  bool _isLock = false;

  /// True if the data has been cloned.
  bool get isCloned => this._isCloned;

  /// Set clone state. True if the [isCloned] has been cloned.
  ///
  /// [isCloned]: True if the [isCloned] has been cloned.
  set isCloned(bool isCloned) => this._isCloned = isCloned;
  bool _isCloned = false;

  /// Create clone Path information and data status are cloned.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  T clone<T extends IClonable>({String path, bool isTemporary = false}) {
    isTemporary = isTemporary || isEmpty(path);
    path = isTemporary ? null : path;
    if (isNotEmpty(path)) {
      T cloned = this._getCloned<T>(path);
      if (cloned != null) {
        cloned.setCloneInternal(this, path, isTemporary);
        return cloned;
      }
    }
    if (isEmpty(path)) path = Texts.uuid;
    T clonable = this.createInstance<T>(path, isTemporary);
    clonable.setCloneInternal(this, path, isTemporary);
    return clonable;
  }

  /// Copy object to [dist].
  ///
  /// [dist]: Destination object [isTemporary]: True if the data is temporary.
  T copyTo<T extends IClonable>(T dist, {bool isTemporary = false}) {
    if (dist == null) return dist;
    dist.setCloneInternal(
        this,
        dist.isTemporary || isTemporary ? null : dist.path,
        dist.isTemporary || isTemporary);
    return dist;
  }

  /// Set information when cloning.
  ///
  /// [clone]: IClonable object.
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @protected
  void setCloneInternal(IClonable clonable, String path, bool isTemporary) {
    if (isEmpty(path)) path = Texts.uuid;
    if (this.path != path) this._path = Path(path);
    this._isTemporary = isTemporary;
    this._group = clonable.group;
    this._order = clonable.order;
    this._isLock = false;
    this._isCloned = true;
    this._isDisposed = false;
    if (clonable is Collection)
      clonable.forEach((child) => this.setInternal(child));
    this.notifyUpdate();
  }

  T _getCloned<T extends IClonable>(String path) => PathMap.get<T>(path);

  /// True if monitoring is possible.
  bool get isObservable => false;
  // Get updated time (ms).
  int get updatedTime {
    for (TChild tmp in this.data.values) {
      if (tmp.updatedTime > this._updatedTime)
        this._updatedTime = tmp.updatedTime;
    }
    return this._updatedTime;
  }

  int _updatedTime = 0;

  /// Notify object update Notifications spread to related objects.
  ///
  /// However, updatedTime is not notified to newer objects.
  ///
  /// [updatedTime]: Updated time (ms). If it is less than 0,
  /// it will be obtained automatically from the application.
  @mustCallSuper
  void notifyUpdate([int updatedTime = -1]) {
    if (updatedTime < 0)
      updatedTime = DateTime.now().frameMillisecondsSinceEpoch;
    if (updatedTime <= this._updatedTime) return;
    this._updatedTime = updatedTime;
    for (IChild tmp in this.data.values) tmp?.notifyUpdate(updatedTime);
    PathListener._updateNotify(this);
  }

  /// Link with another path.
  ///
  /// You can access the same object even if you access the linked path.
  ///
  /// If the path of the actual object exists, it takes precedence.
  ///
  /// If the link destination is a link, it will be overwritten.
  ///
  /// [path]: Link destination path.
  void linkTo(String path) {
    PathMap.link(this.path, path);
    this
        .data
        ?.forEach((key, value) => value?.linkTo(Paths.child(path, value?.id)));
  }

  /// Callback event when application pauses.
  ///
  /// [pause]: True when application is paused, False when returning from pause.
  void onApplicationPause(bool pause) {}

  /// Callback event when application quit.
  void onApplicationQuit() {}

  /// True if the object can be destroyed.
  bool get isDisposable => this._isDisposable;
  bool _isDisposable = true;

  /// True if the object has been destroyed.
  bool get isDisposed => this._isDisposed;
  bool _isDisposed = false;

  /// Callback executed at Dispose.
  ///
  /// [callback]: Callback.
  T onDispose<T extends IDisposable>(void callback(T disposable)) {
    if (callback != null) this._onDispose = () => callback(this as T);
    return this as T;
  }

  void Function() _onDispose;

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  @mustCallSuper
  void dispose() {
    if (this.isDisposed || !this.isDisposable) return;
    this._isDisposed = true;
    if (this._onDispose != null) this._onDispose();
    for (TChild child in this.data.values.toList()) this.unsetInternal(child);
    this.data.clear();
    PathMap.remove(this);
    Log.ast("Disposed object: %s", [this.path]);
  }
}
