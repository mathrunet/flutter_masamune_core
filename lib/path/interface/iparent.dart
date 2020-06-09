part of masamune.path;

/// Interface indicating that you are a parent of the IPath object.
///
/// Please implement and use.
abstract class IParent implements IPath, ILockable, IObservable, IClonable {
  /// Remove child association from parent.
  ///
  /// [child]: Child to remove.
  void _removeChildInternal(IChild child);

  /// Add child association from parent.
  ///
  /// [child]: Child to add.
  void _addChildInernal(IChild child);
}

/// IParent extension methods.
extension IParentSetExtension on Set<IParent> {
  /// Notify object update.
  ///
  /// Notifications spread to related objects.
  ///
  /// However, updatedTime is not notified to newer objects.
  ///
  /// [updatedTime]: Updated time (ms). If it is less than 0,
  /// it will be obtained automatically from the application.
  void notifyUpdate([int updatedTime = -1]) =>
      this.forEach((parent) => parent.notifyUpdate(updatedTime));
}
