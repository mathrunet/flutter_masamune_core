part of masamune.interface;

/// Interface where objects can be reordered.
///
/// Please implement and use.
abstract class IOrderable {
  /// Get the order, the lower the number, the faster.
  int get order;
}
