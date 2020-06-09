part of masamune.interface;

/// Interface for monitoring objects.
///
/// Please implement and use.
abstract class IObservable {
  /// True if monitoring is possible.
  bool get isObservable;

  /// Get updated time (ms).
  int get updatedTime;

  /// Notify object update.
  ///
  /// Notifications spread to related objects.
  ///
  /// However, updatedTime is not notified to newer objects.
  ///
  /// [updatedTime]: Updated time (ms). If it is less than 0,
  /// it will be obtained automatically from the application.
  void notifyUpdate([int updatedTime = -1]);
}
