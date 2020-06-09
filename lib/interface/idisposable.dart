part of masamune.interface;

/// Interface that objects can be destroyed.
///
/// Please implement and use.
abstract class IDisposable {
  /// True if the object can be destroyed.
  bool get isDisposable;

  /// True if the object has been destroyed.
  bool get isDisposed;

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  void dispose();

  /// Callback executed at Dispose.
  ///
  /// [callback]: Callback.
  T onDispose<T extends IDisposable>(void callback(T disposable));

  /// Callback event when application quit.
  void onApplicationQuit();

  /// Callback event when application pauses.
  ///
  /// [pause]: True when application is paused, False when returning from pause.
  void onApplicationPause(bool pause);
}
