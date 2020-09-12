part of masamune.path;

/// Abstract class of the path model.
abstract class Model<T extends Object> implements IPath {
  /// Model context.
  @protected
  ModelContext<T> get context => this._context;
  ModelContext<T> _context;

  /// The data output from the model.
  @protected
  T get data => this.context._data;

  /// The abstract class of the path model.
  @mustCallSuper
  Model() {
    String path = this.runtimeType.hashCode.toString();
    Model model = PathMap.get<Model>(path);
    if (model != null) {
      this._context = model.context;
    } else {
      this._context = ModelContext<T>._(path);
      FutureOr<T> res = this.build(this.context);
      if (res is Future<T>)
        res.then((value) => this.context._data = value);
      else if (res is T) this.context._data = res;
      PathMap.add(this);
    }
  }

  /// Method for building.
  ///
  /// [context]: ModelContext.
  @protected
  FutureOr<T> build(ModelContext context);

  /// Load the data again.
  Future<T> load() async {
    T result = await this.build(this.context);
    this.context._data = result;
    return result;
  }

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  @protected
  @mustCallSuper
  void dispose() {
    if (this.isDisposed || !this.isDisposable) return;
    this.context._dispose();
    if (this._onDispose != null) this._onDispose();
    PathMap.remove(this);
    PathListener._updateNotify(this);
    Log.ast("Disposed object: %s", [this.path]);
  }

  /// Debug output.
  ///
  /// The debug output differs depending on the object.
  ///
  /// [value]: The object to enter.
  @override
  @protected
  T debug<T extends IDebuggable>([Object value]) {
    if (value != null)
      Log.msg(value);
    else
      Log.msg("PathModel[%s][%s]\n%s",
          [this.runtimeType, this.path, this.toString()]);
    return this as T;
  }

  /// Get the path extension.
  @protected
  final String extension = Const.empty;

  /// Get group number.
  @protected
  final int group = 0;

  /// Get the path.
  @protected
  String get path => this.rawPath.url;

  /// Get ID.
  ///
  /// Usually the string of the child of the path.
  @protected
  String get id {
    if (isEmpty(this.rawPath.file)) return Const.empty;
    return this.rawPath.file;
  }

  /// True if the object can be destroyed.
  @protected
  final bool isDisposable = true;

  /// True if the object has been destroyed.
  @override
  @protected
  bool get isDisposed => this.context.isDisposed;

  /// True if monitoring is possible.
  @protected
  final bool isObservable = false;

  /// True if the object is temporary data.
  @protected
  final bool isTemporary = false;

  /// Link with another path.
  ///
  /// You can access the same object even if you access the linked path.
  ///
  /// If the path of the actual object exists, it takes precedence.
  ///
  /// If the link destination is a link, it will be overwritten.
  ///
  /// [path]: Link destination path.
  @protected
  void linkTo(String path) => PathMap.link(this.path, path);

  /// Get updated time (ms).
  @protected
  int get updatedTime => this.context.updatedTime;

  /// Notify object update.
  ///
  /// Notifications spread to related objects.
  ///
  /// However, updatedTime is not notified to newer objects.
  ///
  /// [updatedTime]: Updated time (ms). If it is less than 0, it will be obtained automatically from the application.
  @override
  @protected
  void notifyUpdate([int updatedTime = -1]) {
    if (updatedTime < 0)
      updatedTime = DateTime.now().frameMillisecondsSinceEpoch;
    if (updatedTime <= this.context.updatedTime) return;
    this.context._notifyUpdate(updatedTime);
    PathListener._updateNotify(this);
  }

  /// Callback event when application pauses.
  ///
  /// [pause]: True when application is paused, False when returning from pause.
  @override
  @protected
  void onApplicationPause(bool pause) {}

  /// Callback event when application quit.
  @override
  @protected
  void onApplicationQuit() {}

  /// Callback executed at Dispose.
  ///
  /// [callback]: Callback.
  T onDispose<T extends IDisposable>(void callback(T disposable)) {
    if (callback != null) this._onDispose = () => callback(this as T);
    return this as T;
  }

  void Function() _onDispose;

  /// Get the protocol of the path.
  @override
  @protected
  final int order = 0;

  /// Get the protocol of the path.
  @override
  @protected
  final String protocol = Protocol.model;

  /// Get the path structure.
  @protected
  Path get rawPath => this.context._rawPath;

  /// Register the temporary data in the path map.
  ///
  /// Not registered if the protocol is temporary.
  @protected
  void registerUntemporary() {}
}

class ModelContext<T extends Object> {
  T _data;
  final Path _rawPath;
  void _dispose() {
    if (this._data is IPath) (this._data as IPath).dispose();
    this._isDisposed = true;
  }

  /// Model Path.
  String get path => this._rawPath.url;
  ModelContext._(String path) : this._rawPath = Path(path);

  /// True. if the model is destroyed.
  bool get isDisposed => this._isDisposed;
  bool _isDisposed;

  /// Get updated time (ms).
  int get updatedTime => this._updatedTime;
  int _updatedTime = 0;

  /// Notify object update.
  ///
  /// Notifications spread to related objects.
  ///
  /// However, updatedTime is not notified to newer objects.
  ///
  /// [updatedTime]: Updated time (ms). If it is less than 0, it will be obtained automatically from the application.
  void _notifyUpdate([int updatedTime = -1]) {
    this._updatedTime = updatedTime;
  }
}
