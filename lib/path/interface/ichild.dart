part of masamune.path;

/// Interface indicating that you are a child of the IPath object.
///
/// Please implement and use.
abstract class IChild implements IPath, ILockable, IObservable, IClonable {
  /// Remove parent relationship from child.
  ///
  /// [parent]: The parent whose relationship is to be deleted.
  void _removeParentInternal(IParent parent);

  /// Add parent relationship from child.
  ///
  /// [parent]: The parent whose relationship is to be added.
  void _addParentInternal(IParent parent);
}
