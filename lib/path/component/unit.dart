part of masamune.path;

/// Abstract class for defining Unit.
///
/// Store data in unit.
///
/// You can also extend the unit to manage tasks.
///
/// Please inherit and use.
abstract class Unit<TValue extends Object>
    implements IPath, IUnit<TValue>, IChild {
  /// Get the data.
  TValue get data {
    TValue data = PathFilter.getTemporary(this.path);
    if (data != null) return data;
    data = this._data;
    data = PathFilter.applyGetFilter(this.path, data);
    return data;
  }

  /// Set the data.
  ///
  /// [value]: Data to set.
  set data(TValue value) {
    if (PathFilter.setTemporary(this.path, value)) return;
    value = PathFilter.applySetFilter(this.path, value);
    this.setInternal(value);
  }

  /// Get the raw data.
  TValue get rawData => this._data;
  TValue _data;

  /// When map data is stored.
  /// You can get the data by specifying the path.
  ///
  /// [path]: The path to get the data.
  dynamic operator [](String path) {
    if (isEmpty(path)) return null;
    dynamic tmp = this.data;
    path = path.trimString(Const.slash);
    List<String> paths = path.split(Const.slash);
    try {
      for (int i = 0; i < paths.length; i++) {
        if (tmp is Map) {
          tmp = (tmp as Map)[paths[i]];
        } else if (tmp is List) {
          int n = int.tryParse(paths[i]);
          if (n == null) continue;
          tmp = (tmp as List)[n];
        }
      }
      return tmp;
    } catch (e) {}
    return null;
  }

  /// Abstract class for defining Unit.
  ///
  /// Store data in unit.
  ///
  /// You can also extend the unit to manage tasks.
  ///
  /// Please inherit and use.
  ///
  /// [path]: Unit path.
  /// [value]: Unit value.
  /// [isTemporary]: True if it is temporary data.
  /// [group]: Unit group (0 or more).
  /// [order]: Unit order.
  @protected
  Unit(String path,
      {TValue value, bool isTemporary = false, int group = 0, int order = 10}) {
    if (isEmpty(path)) path = Texts.uuid;
    this._path = Path(path);
    this._order = order;
    this._isTemporary = isTemporary;
    if (group < -1) group = -1;
    this._group = group;
    value = PathFilter.applySetFilter(this.path, value);
    this.setInternal(value);
    if (!this.isTemporary) PathMap.add(this);
  }

  /// Processing to set a value.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: Value to set.
  @protected
  void setInternal(TValue value) {
    if (this.isLock) {
      Log.warning("Data modification is prohibited.");
      return;
    }
    if (this.rawData == value)
      return;
    else
      this._data = value;
    this.notifyUpdate();
  }

  /// Processing to delete values.
  ///
  /// Do not use from outside the class.
  @protected
  void unsetInternal() => this._data = null;

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

  /// Get group number.
  int get group => this._group;
  int _group = 0;

  /// Get the order, the lower the number, the faster.
  int get order => this._order;
  int _order = 0;

  /// True if object is locked.
  bool get isLock => this._isLock;
  bool _isLock = false;

  /// Debug output The debug output differs depending on the object.
  ///
  /// [value]: The object to enter
  T debug<T extends IDebuggable>([Object value]) {
    if (value != null)
      Log.msg(value);
    else
      Log.msg(
          "Unit[%s][%s]\n%s", [this.runtimeType, this.path, this.toString()]);
    return this as T;
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    if (this.data is List) {
      return Json.encode(this.data as List);
    } else if (this.data is Map) {
      return Json.encode(this.data as Map);
    } else {
      return (this.data?.toString());
    }
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
    if (clonable is Unit) this.setInternal(clonable.rawData);
    this.notifyUpdate();
  }

  T _getCloned<T extends IClonable>(String path) => PathMap.get<T>(path);

  /// True if monitoring is possible.
  bool get isObservable => false;

  /// Get updated time (ms).
  int get updatedTime => this._updatedTime;
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
  void linkTo(String path) => PathMap.link(this.path, path);

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
    for (IParent parent in this._parent.toList())
      parent._removeChildInternal(this);
    this.unsetInternal();
    PathMap.remove(this);
    PathListener._updateNotify(this);
    Log.ast("Disposed object: %s", [this.path]);
  }
}
