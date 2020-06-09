part of masamune.dartcore;

/// Class that outputs logs.
///
/// ```
/// Log.msg( "Log message" );
/// ```
class Log {
  /// True to display Assert.
  static bool isShowAssert = false;

  /// True for Debug build.
  static bool get isDebugBuild {
    if (!_isDebugBuildApplied) {
      _isDebugBuildApplied = true;
      _isDebugBuild = false;
      assert(_isDebugBuild = true);
    }
    return _isDebugBuild;
  }

  /// Set whether it is a debug build.
  ///
  /// [value]: True for debug builds.
  static set isDebugBuild(bool value) {
    _isDebugBuild = value;
    _isDebugBuildApplied = true;
  }

  static bool _isDebugBuild = false;
  static bool _isDebugBuildApplied = false;

  /// Print a stack trace.
  ///
  /// No log is output if it is not a debug build.
  static void stackTrace() {
    if (!isDebugBuild) return;
    List<Frame> frames = Trace.current(1).frames;
    for (Frame frame in frames) {
      print(frame.toString());
    }
  }

  /// Prints log messages as assert.
  ///
  /// No log is output if it is not a debug build.
  ///
  /// [message]: Message to output (format can be used).
  /// [args]: Argument when [message] is formatted.
  static void ast(Object message, [Iterable<Object> args]) {
    if (!isDebugBuild || !isShowAssert) return;
    if (args == null || args.length <= 0)
      print(message);
    else
      print(Texts.format(message?.toString(), args));
  }

  /// Prints log messages.
  ///
  /// No log is output if it is not a debug build.
  ///
  /// [message]: Message to output (format can be used).
  /// [args]: Argument when [message] is formatted.
  static void msg(Object message, [Iterable<Object> args]) {
    if (!isDebugBuild) return;
    if (args == null || args.length <= 0)
      print(message);
    else
      print(Texts.format(message?.toString(), args));
  }

  /// Prints log messages as error.
  ///
  /// No log is output if it is not a debug build.
  ///
  /// [message]: Message to output (format can be used).
  /// [args]: Argument when [message] is formatted.
  static void error(Object message, [Iterable<Object> args]) {
    if (!isDebugBuild) return;
    if (args == null || args.length <= 0)
      print(message);
    else
      print(Texts.format(message?.toString(), args));
  }

  /// Prints log messages as warning.
  ///
  /// No log is output if it is not a debug build.
  ///
  /// [message]: Message to output (format can be used).
  /// [args]: Argument when [message] is formatted.
  static void warning(Object message, [Iterable<Object> args]) {
    if (!isDebugBuild) return;
    if (args == null || args.length <= 0)
      print(message);
    else
      print(Texts.format(message?.toString(), args));
  }
}
