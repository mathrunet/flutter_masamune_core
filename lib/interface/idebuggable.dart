part of masamune.interface;

/// Interface where objects can be debugged.
///
/// Please implement and use.
abstract class IDebuggable {
  /// Debug output.
  ///
  /// The debug output differs depending on the object.
  ///
  /// [value]: The object to enter.
  T debug<T extends IDebuggable>([Object value]);
}

/// Future extension methods for IDebuggable.
extension FutureIDebuggableExtension<T extends IDebuggable> on Future<T> {
  /// Debug output.
  ///
  /// The debug output differs depending on the object.
  ///
  /// [value]: The object to enter.
  Future<T> debug([Object value]) {
    return this?.then((debug) => debug?.debug(value));
  }
}
