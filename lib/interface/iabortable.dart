part of masamune.interface;

/// Interruptible interface.
///
/// Please implement and use.
abstract class IAbortable {
  /// True if the object was interrupted.
  bool get isAbort;

  /// Abort the object.
  ///
  /// Displays the abort [message].
  ///
  /// [message]: Interruption message.
  T abort<T extends IAbortable>([String message = Const.empty]);
}
