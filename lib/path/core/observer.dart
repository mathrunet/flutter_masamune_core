part of masamune.path;

/// Object for monitoring.
///
/// Pass it by instantiating it to PathListener etc. and [dispose()] it when Disposed.
///
/// ```
/// PathListener( "user/user", () => ..., Observer observer = Obserber() );
/// observer.dispose();
/// ```
class Observer {
  /// True if the target process has been deleted.
  bool get isDisposed => this._isDisposed;
  bool _isDisposed = false;

  /// Object for monitoring.
  ///
  /// Pass it by instantiating it to PathListener etc. and [dispose()] it when Disposed.
  ///
  /// ```
  /// PathListener( "user/user", () => ..., Observer observer = Obserber() );
  /// observer.dispose();
  /// ```
  Observer();

  /// Dispose Observer and delete the target process.
  void dispose() => this._isDisposed = true;
}
