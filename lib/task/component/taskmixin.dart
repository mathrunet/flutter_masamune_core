part of masamune.task;

/// Mixin class to add processing for task.
///
/// Please mix in and use.
mixin TaskMixin on IPath implements ITask {
  Completer _completer;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @protected
  Completer createCompleter();

  /// Returns the [Future] class of the task.
  ///
  /// Normally, use it inside a class. Do not use outside the class.
  Future get future => this._completer?.future;

  /// True when the object has finished executing.
  bool get isDone => this._isDone;
  bool _isDone = false;

  /// True if the object is in error.
  bool get isError => this._isError;
  bool _isError = false;

  /// True if the task has timed out.
  bool get isTimeout => this._isTimeout;
  bool _isTimeout = false;

  /// True if object or application is restricted.
  bool get isRestricted => this._isRestricted;

  /// True if object or application is restricted.
  ///
  /// [isRestricted]: True if object or application is restricted.
  @protected
  set isRestricted(bool isRestricted) => this._isRestricted = isRestricted;
  bool _isRestricted = false;

  /// True if not connected to network.
  bool get isNotReachableNetwork => this._isNotReachableNetwork;

  /// True if not connected to network.
  ///
  /// [isNotReachableNetwork]: True if not connected to network.
  @protected
  set isNotReachableNetwork(bool isNotReachableNetwork) =>
      this._isNotReachableNetwork = isNotReachableNetwork;
  bool _isNotReachableNetwork = false;

  /// True when system is not supported.
  bool get isNotSupported => this._isNotSupported;

  /// True when system is not supported.
  ///
  /// [isNotSupported]: True when system is not supported.
  @protected
  set isNotSupported(bool isNotSupported) =>
      this._isNotSupported = isNotSupported;
  bool _isNotSupported = false;

  /// True if object or data is duplicated.
  bool get isDuplicate => this._isDuplicate;

  /// True if object or data is duplicated.
  ///
  /// [isDuplicate]: True if object or data is duplicated.
  @protected
  set isDuplicate(bool isDuplicate) => this._isDuplicate = isDuplicate;
  bool _isDuplicate = false;

  /// True if object or data not found.
  bool get isNotFound => this._isNotFound;

  /// True if object or data not found.
  ///
  /// [isNotFound]: True if object or data not found.
  @protected
  set isNotFound(bool isNotFound) => this._isNotFound = isNotFound;
  bool _isNotFound = false;

  /// Get error message.
  String get message => this._message;
  String _message;

  /// Gets the progress (0.0 - 1.0).
  double get progress => this._progress;

  /// Sets the progress (0.0 - 1.0).
  ///
  /// [progress]: Progress value
  @protected
  set progress(double progress) => this._progress = progress;
  double _progress = 0;

  /// Initialize execution.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  @protected
  @mustCallSuper
  T init<T extends IDoable>() {
    if (this._completer.isCompleted) this._completer = this.createCompleter();
    this._isDone = this._isError = this._isAbort = false;
    this._isNotSupported = this._isDuplicate = this._isRestricted =
        this._isNotFound = this._isNotReachableNetwork = false;
    this.isCloned = false;
    this.progress = 0;
    this._message = null;
    return this as T;
  }

  /// Exit as successful.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  @protected
  @mustCallSuper
  T done<T extends IDoable>() {
    if (this.isDone) return this as T;
    this._isDone = true;
    this._isError = this._isAbort = false;
    this.progress = 1;
    this._message = null;
    this._completer.complete(this);
    this.notifyUpdate();
    return this as T;
  }

  /// Terminates processing with an error.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  ///
  /// [message]: Error message.
  /// [errorLevel]: Set the error level.
  @protected
  @mustCallSuper
  T error<T extends IErrorable>(String message,
      {ErrorLevel errorLevel = ErrorLevel.error}) {
    this._isDone = this._isError = true;
    this._isAbort = false;
    this._message = message;
    this.progress = 1;
    this._errorLevel = errorLevel;
    if (errorLevel == ErrorLevel.warning)
      Log.warning(message);
    else if (errorLevel == ErrorLevel.error) Log.error(message);
    this._completer.complete(this);
    return this as T;
  }

  /// Processing when task times out.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  ///
  /// [message]: Error message.
  /// [errorLevel]: Set the error level.
  @protected
  @mustCallSuper
  T timeout<T extends IErrorable>(String message,
      {ErrorLevel errorLevel = ErrorLevel.error}) {
    this._isTimeout = true;
    return this.error(message, errorLevel: errorLevel);
  }

  /// Get error level.
  ErrorLevel get errorLevel => this._errorLevel;
  ErrorLevel _errorLevel = ErrorLevel.none;

  /// True if the object was interrupted.
  bool get isAbort => this._isAbort;
  bool _isAbort = false;

  /// Abort the object.
  ///
  /// Displays the abort [message].
  ///
  /// [message]: Interruption message.
  @mustCallSuper
  T abort<T extends IAbortable>([String message = Const.empty]) {
    this._isAbort = this._isDone = true;
    this._isError = false;
    this._message = message;
    this._completer.complete(this);
    return this as T;
  }

  /// True if the object is cached.
  bool get isCached => false;

  /// True if object is locked.
  bool get isLock => false;
}
