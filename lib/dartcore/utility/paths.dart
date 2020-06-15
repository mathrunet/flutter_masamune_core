part of masamune.dartcore;

/// Path-related utilities.
///
/// It can be used for URLs as well as paths.
class Paths {
  static final RegExp _tail = RegExp(r"[^/]+$");
  static final RegExp _scheme = RegExp(r"^[^:]+://");

  /// Measure the length of [path].
  ///
  /// By entering [separator], it can be used for purposes other than paths.
  ///
  /// [path]: Path to use.
  /// [separator]: Separator, default is [/].
  static int length(String path, {String separator = Const.slash}) {
    if (isEmpty(path)) return 0;
    try {
      path = path.replaceAll(_scheme, Const.empty);
      List<String> paths = path.split(separator);
      int length = paths.length;
      paths.release();
      return length;
    } catch (e) {}
    return 0;
  }

  /// Extracts the character at the specified number from the shallow part of [path].
  ///
  /// By entering [separator], it can be used for purposes other than paths.
  ///
  /// [path]: Path to use.
  /// [index]: Number to get (0 shallow).
  /// [separator]: Separator, default is [/].
  static String get(String path, int index, {String separator = Const.slash}) {
    try {
      if (isEmpty(path) || index < 0) return null;
      List<String> paths = path.split(separator);
      String res = paths[index];
      paths.release();
      return res;
    } catch (e) {}
    return null;
  }

  /// Get the shallowest part of [path].
  ///
  /// By entering [separator], it can be used for purposes other than paths.
  ///
  /// [path]: Path to use.
  /// [separator]: Separator, default is [/].
  static String first(String path, {String separator = Const.slash}) {
    try {
      if (isEmpty(path)) return null;
      List<String> paths = path.split(separator);
      String res = paths.firstOrNull;
      paths.release();
      return res;
    } catch (e) {}
    return null;
  }

  /// Get the deepest part of [path].
  ///
  /// By entering [separator], it can be used for purposes other than paths.
  ///
  /// [path]: Path to use.
  /// [separator]: Separator, default is [/].
  static String last(String path, {String separator = Const.slash}) {
    try {
      if (isEmpty(path)) return null;
      List<String> paths = path.split(separator);
      return paths.last;
    } catch (e) {}
    return null;
  }

  /// Path of one parent of [path].
  ///
  /// By entering [separator], it can be used for purposes other than paths.
  ///
  /// [path]: Path to use.
  /// [separator]: Separator, default is [/].
  static String parent(String path, {String separator = Const.slash}) {
    try {
      if (isEmpty(path)) return null;
      path = path.trimString(separator);
      return path.replaceAll(_tail, Const.empty).trimStringRight(separator);
    } catch (e) {}
    return null;
  }

  /// Returns one deep path with [child] appended to [path].
  ///
  /// By entering [separator], it can be used for purposes other than paths.
  ///
  /// [path]: Path to use.
  /// [child]: The string to add.
  /// [separator]: Separator, default is [/].
  static String child(String path, String child,
      {String separator = Const.slash}) {
    try {
      if (isEmpty(child)) return path;
      path = path?.trimString(separator);
      if (isEmpty(path)) return child;
      return path + Const.slash + child;
    } catch (e) {}
    return null;
  }

  /// Divides the [path] and returns it as an array.
  ///
  /// By entering [separator], it can be used for purposes other than paths.
  ///
  /// [path]: Path to use.
  /// [separator]: Separator, default is [/].
  static List<String> split(String path, {String separator = Const.slash}) {
    try {
      if (isEmpty(child)) return ListPool.get();
      path = path?.trimString(separator);
      if (isEmpty(path)) return ListPool.get();
      return path.split(separator);
    } catch (e) {}
    return null;
  }
}
