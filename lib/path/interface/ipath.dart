part of masamune.path;

/// Interface that can manage data by path.
///
/// Please implement and use.
abstract class IPath
    implements
        IGroupable,
        IDisposable,
        IOrderable,
        ICastable,
        IObservable,
        IDebuggable {
  /// Get the path.
  String get path;

  /// Get ID.
  ///
  /// Usually the string of the child of the path.
  String get id;

  /// True if the object is temporary data.
  bool get isTemporary;

  /// Register the temporary data in the path map.
  ///
  /// Not registered if the protocol is temporary.
  @protected
  void registerUntemporary();

  /// Get the protocol of the path.
  String get protocol;

  /// Get the path extension.
  String get extension;

  /// Get the path structure.
  Path get rawPath;

  /// Link with another path.
  ///
  /// You can access the same object even if you access the linked path.
  ///
  /// If the path of the actual object exists, it takes precedence.
  ///
  /// If the link destination is a link, it will be overwritten.
  ///
  /// [path]: Link destination path.
  void linkTo(String path);
}
