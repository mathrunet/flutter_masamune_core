part of masamune.interface;

/// Interface that allows objects to be error managed.
///
/// Please implement and use.
abstract class IErrorable {
  /// True if the object is in error.
  bool get isError;

  /// True if the task has timed out.
  bool get isTimeout;

  /// True if object or application is restricted.
  bool get isRestricted;

  /// True if not connected to network.
  bool get isNotReachableNetwork;

  /// True when system is not supported.
  bool get isNotSupported;

  /// True if object or data not found.
  bool get isNotFound;

  /// True if object or data is duplicated.
  bool get isDuplicate;

  /// Get error message.
  String get message;

  /// Get error level.
  ErrorLevel get errorLevel;

  /// Terminates processing with an error.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  ///
  /// [message]: Error message.
  /// [errorLevel]: Set the error level.
  @protected
  T error<T extends IErrorable>(String message,
      {ErrorLevel errorLevel = ErrorLevel.error});
}
