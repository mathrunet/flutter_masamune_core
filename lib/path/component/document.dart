part of masamune.path;

/// Abstract class that manages data with key-value pairs.
///
/// The key is fixed at String. Value can include IChild class,
/// so it is possible to store Document itself as well as Unit.
///
/// It is compatible with documents such as Firestore and can be used as it is.
///
/// Please inherit and use.
abstract class Document<TChild extends IChild>
    implements IPath, IDocument<TChild>, IParent, IChild {
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

  /// Abstract class that manages data with key-value pairs.
  ///
  /// The key is fixed at String. Value can include IChild class,
  /// so it is possible to store Document itself as well as Unit.
  ///
  /// It is compatible with documents such as Firestore and can be used as it is.
  ///
  /// [path]: Document path.
  /// [children]: Initial document data, using TChild array.
  /// [isTemporary]: True if it is temporary data.
  /// [group]: Unit group (0 or more).
  /// [order]: Unit order.
  @protected
  Document(String path,
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
    if (this.data.containsKey(key)) {
      if (value != this.data[key]) value.copyTo(this.data[key]);
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
  void unsetInternal(TChild value) {
    if (value == null) return;
    if (!this.data.containsKey(value.id)) return;
    value?._removeParentInternal(this);
    value?.dispose();
    this.data.remove(value.id);
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

  /// Add child association from parent.
  ///
  /// [child]: Child to add.
  void _addChildInernal(IChild child) {
    if (!(child is TChild)) return;
    if (isEmpty(child.path) || Paths.parent(child.path) != this.path) return;
    if (this.data.containsKey(child.id) || this.data.containsValue(child))
      return;
    this.setInternal(child);
    Log.ast("Adding child: %s(%s)", [child.path, child]);
  }

  /// Remove child association from parent.
  ///
  /// [child]: Child to remove.
  void _removeChildInternal(IChild child) {
    if (!(child is TChild)) return;
    if (isEmpty(child.path) || Paths.parent(child.path) != this.path) return;
    this.unsetInternal(child);
    Log.ast("Removing child: %s(%s)", [child.path, child]);
  }

  /// Remove parent relationship from child.
  ///
  /// [parent]: The parent whose relationship is to be deleted.
  void _removeParentInternal(IParent parent) => this._parent.remove(parent);

  /// Add parent relationship from child.
  ///
  /// [parent]: The parent whose relationship is to be added.
  void _addParentInternal(IParent parent) => this._parent.add(parent);
  Set<IParent> _parent = SetPool.get();

  /// Get number of documents.
  int get length => this.data.length;

  /// Get the document key list
  Iterable<String> get keys => this.data.keys;

  /// Get a list of values for a document
  Iterable<TChild> get values => this.data.values;

  /// Get a list of key-value pairs
  Iterable<MapEntry<String, TChild>> get entries => this.data.entries;

  /// Check if the document contains a key.
  ///
  /// True if key is included.
  ///
  /// [key]: Key to check.
  bool containsKey(String key) {
    if (isEmpty(key)) return false;
    return this.data.containsKey(key);
  }

  /// Iterates the contents of the document using [key] and [value].
  ///
  /// [function]: Iterative processing of [key] and [value].
  void forEach(void function(String key, TChild value)) {
    Iterable<String> keys = this.data.keys;
    for (String key in keys) {
      function(key, this.data[key]);
    }
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

  /// Remove data from document.
  ///
  /// [key]: Key to delete.
  void remove(String key) {
    assert(isNotEmpty(key));
    if (isEmpty(key)) return;
    if (this.isLock) {
      Log.warning("Data modification is prohibited.");
      return;
    }
    if (!this.data.containsKey(key)) return;
    this.unsetInternal(this.data[key]);
    this.data.remove(key);
    this.notifyUpdate();
  }

  /// Remove data from document.
  ///
  /// [keys]: Keys to delete.
  void removeAll(Iterable<String> keys) {
    assert(keys != null);
    if (keys == null) return;
    if (this.isLock) {
      Log.warning("Data modification is prohibited.");
      return;
    }
    for (String key in keys) {
      if (isEmpty(key) || !this.data.containsKey(key)) continue;
      this.unsetInternal(this.data[key]);
      this.data.remove(key);
    }
    this.notifyUpdate();
  }

  /// Deletes the element conditionally.
  ///
  /// [predicate]: Csonditions. If True, delete.
  void removeWhere(bool predicate(String key, TChild child)) {
    if (predicate == null) return;
    List<MapEntry<String, TChild>> remove =
        this.data.where((key, value) => predicate(key, value)).toList();
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
  T debug<T extends IDebuggable>([Object value]) {
    Log.msg("Document[%s][%s]\n%s",
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
    if (clonable is Document)
      clonable.values.forEach((child) => this.setInternal(child));
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
    this._parent?.notifyUpdate(updatedTime);
    for (TChild tmp in this.data.values) tmp?.notifyUpdate(updatedTime);
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
  /// [path]: Link destination path
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
    for (IParent parent in this._parent) parent._removeChildInternal(this);
    for (TChild child in this.data.values.toList()) this.unsetInternal(child);
    this._parent.clear();
    this.data.clear();
    PathMap.remove(this);
    Log.ast("Disposed object: %s", [this.path]);
  }
}
