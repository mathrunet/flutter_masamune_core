part of masamune.interface;

/// Interface that can track the progress.
///
/// Please implement and use.
abstract class IProgressable {
  /// Gets the progress (0.0 - 1.0).
  double get progress;
}
