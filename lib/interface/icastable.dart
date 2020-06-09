part of masamune.interface;

/// Interface where objects can be cast.
///
/// Please implement and use.
abstract class ICastable {}

/// Extension method of ICastable class.
extension ICastableExtension on ICastable {
  /// Cast object to [T].
  T to<T extends ICastable>() => this as T;

  /// Check if it is of the specified type.
  ///
  /// True if it matches the type.
  bool isType<T extends ICastable>() => this is T;
}
