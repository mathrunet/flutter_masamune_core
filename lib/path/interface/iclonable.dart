part of masamune.path;

/// Interface where objects can be cloned.
///
/// Please implement and use.
abstract class IClonable implements IPath {
  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary);

  /// Set information when cloning.
  ///
  /// [clone]: IClonable object.
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @protected
  void setCloneInternal(IClonable clone, String path, bool isTemporary);

  /// True if the data has been cloned.
  bool get isCloned;

  /// Set clone state. True if the [isCloned] has been cloned.
  ///
  /// [isCloned]: True if the [isCloned] has been cloned.
  set isCloned(bool isCloned);

  /// Create clone.
  ///
  /// Path information and data status are cloned.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  T clone<T extends IClonable>({String path, bool isTemporary = false});

  /// Copy object to [dist].
  ///
  /// [dist]: Destination object.
  /// [isTemporary]: True if the data is temporary.
  T copyTo<T extends IClonable>(T dist, {bool isTemporary = false});
}
