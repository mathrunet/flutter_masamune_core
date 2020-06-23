part of masamune.auth;

/// Abstract class for performing authentication.
///
/// When [authorized(String)] is executed after the authentication is completed,
/// an ID can be assigned at the end of the task.
///
/// Please inherit and use.
abstract class Auth extends TaskUnit implements IAuth {
  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @protected
  Completer createCompleter() => Completer<Auth>();

  /// Abstract class for performing authentication.
  ///
  /// When [authorized(String)] is executed after the authentication is completed,
  /// an ID can be assigned at the end of the task.
  @protected
  Auth({String path, bool isTemporary = false})
      : super(path: path, isTemporary: isTemporary);

  /// Get the protocol of the path
  @override
  String get protocol => Protocol.system;

  /// User / Universal ID at the time of authentication
  String get uid => this._uid;
  String _uid;

  /// True if authenticated
  bool get isAuthorized => this._isAuthorized;
  bool _isAuthorized;

  /// Execute when authentication is completed.
  ///
  /// Do not use from external class.
  ///
  /// [uid]: User / Universal ID.
  @protected
  void authorized(String uid) {
    this._uid = uid;
    this.done();
  }

  /// Initialize execution.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  @override
  @protected
  T init<T extends IDoable>() {
    super.init();
    this._uid = null;
    this._isAuthorized = false;
    return this as T;
  }

  /// Exit as successful.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  @override
  @protected
  T done<T extends IDoable>() {
    if (this.isDone) return this as T;
    if (isEmpty(this._uid)) this._uid = Config.uid;
    this._isAuthorized = true;
    super.done();
    return this as T;
  }

  /// Terminates processing with an error.
  /// You can use it publicly, but do not use it from outside the class.
  ///
  /// [message]: Error message.
  /// [errorLevel]: Set the error level.
  @override
  @protected
  T error<T extends IErrorable>(String message,
      {ErrorLevel errorLevel = ErrorLevel.error}) {
    this._uid = null;
    this._isAuthorized = false;
    super.error(message, errorLevel: errorLevel);
    return this as T;
  }

  /// Processing when task times out.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  ///
  /// [message]: Error message.
  /// [errorLevel]: Set the error level.
  @override
  @protected
  T timeout<T extends IErrorable>(String message,
      {ErrorLevel errorLevel = ErrorLevel.error}) {
    this._uid = null;
    this._isAuthorized = false;
    super.timeout(message, errorLevel: errorLevel);
    return this as T;
  }

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  @override
  void dispose() {
    if (this.isDisposed || !this.isDisposable) return;
    this._uid = null;
    this._isAuthorized = false;
    super.dispose();
  }
}
