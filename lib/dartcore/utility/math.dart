part of masamune.dartcore;

/// Utility for numerical calculation.
class Math {
  /// Calculate Lerp from [a] to [b].
  ///
  /// [a]: Starting point.
  /// [b]: Goal point.
  /// [time]: Time (0.0 - 0.1).
  static double lerp(double a, double b, double time) => ((b - a) * time) + a;

  /// Calculate Moduloes of [a] and [b].
  ///
  /// [a]: The value to be divided.
  /// [b]: Divide value.
  static int mod(int a, int b) {
    if (a >= 0) return a % b;
    while (a < 0) a += b;
    return a;
  }

  /// Get a random object.
  static Random get random {
    return Random();
  }
}
