part of masamune.task;

/// Interface for performing tasks.
///
/// [IChild] interface so you can add to collections and documents.
///
/// Please implement and use.
abstract class ITask
    implements
        IPath,
        IChild,
        IDoable,
        IErrorable,
        IProgressable,
        IClonable,
        IObservable,
        IDebuggable,
        ICacheable,
        IDisposable,
        ICastable,
        IWaitable,
        IAbortable {
  /// Returns the [Future] class of the task.
  ///
  /// Normally, use it inside a class. Do not use outside the class.
  Future get future;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @protected
  Completer createCompleter();
}
