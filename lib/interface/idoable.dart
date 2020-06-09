part of masamune.interface;

/// Interface that the object can execute.
///
/// Please implement and use.
abstract class IDoable {
  /// True when the object has finished executing.
  bool get isDone;

  /// Exit as successful.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  @protected
  T done<T extends IDoable>();

  /// Initialize execution.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  @protected
  T init<T extends IDoable>();
}
