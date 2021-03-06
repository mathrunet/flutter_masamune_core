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
  /// You can ignore the rest by using [querySeparator].
  ///
  /// [path]: Path to use.
  /// [separator]: Separator, default is [/].
  /// [querySeparator]: Query parameter, default is [?].
  static int length(String path,
      {String separator = Const.slash,
      String querySeparator = Const.question}) {
    if (isEmpty(path)) return 0;
    try {
      path = path.replaceAll(_scheme, Const.empty);
      if (path.contains(querySeparator))
        path = path.split(querySeparator).first;
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
  /// You can ignore the rest by using [querySeparator].
  ///
  /// [path]: Path to use.
  /// [index]: Number to get (0 shallow).
  /// [separator]: Separator, default is [/].
  /// [querySeparator]: Query parameter, default is [?].
  static String get(String path, int index,
      {String separator = Const.slash,
      String querySeparator = Const.question}) {
    try {
      if (isEmpty(path) || index < 0) return null;
      if (path.contains(querySeparator))
        path = path.split(querySeparator).first;
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
  /// [querySeparator]: Query parameter, default is [?].
  static String first(String path,
      {String separator = Const.slash,
      String querySeparator = Const.question}) {
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
  /// [querySeparator]: Query parameter, default is [?].
  static String last(String path,
      {String separator = Const.slash,
      String querySeparator = Const.question}) {
    try {
      if (isEmpty(path)) return null;
      if (path.contains(querySeparator))
        path = path.split(querySeparator).first;
      List<String> paths = path.split(separator);
      return paths.last;
    } catch (e) {}
    return null;
  }

  /// Get the [path] extension.
  ///
  /// [path]: Path to use.
  static String extension(String path) => last(path, separator: Const.dot);

  /// Path of one parent of [path].
  ///
  /// By entering [separator], it can be used for purposes other than paths.
  ///
  /// [path]: Path to use.
  /// [separator]: Separator, default is [/].
  /// [querySeparator]: Query parameter, default is [?].
  static String parent(String path,
      {String separator = Const.slash,
      String querySeparator = Const.question}) {
    try {
      if (isEmpty(path)) return null;
      if (path.contains(querySeparator)) {
        List<String> paths = path.split(querySeparator);
        path = paths.first;
        path = path.trimString(separator);
        return path.replaceAll(_tail, Const.empty).trimStringRight(separator) +
            querySeparator +
            paths.last;
      } else {
        path = path.trimString(separator);
        return path.replaceAll(_tail, Const.empty).trimStringRight(separator);
      }
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
  /// [querySeparator]: Query parameter, default is [?].
  static String child(String path, String child,
      {String separator = Const.slash,
      String querySeparator = Const.question}) {
    try {
      if (isEmpty(child)) return path;
      if (path.contains(querySeparator)) {
        List<String> paths = path.split(querySeparator);
        path = paths.first;
        path = path?.trimString(separator);
        if (isEmpty(path)) return child + paths.last;
        return path + Const.slash + child + querySeparator + paths.last;
      } else {
        path = path?.trimString(separator);
        if (isEmpty(path)) return child;
        return path + Const.slash + child;
      }
    } catch (e) {}
    return null;
  }

  /// Divides the [path] and returns it as an array.
  ///
  /// By entering [separator], it can be used for purposes other than paths.
  ///
  /// [path]: Path to use.
  /// [separator]: Separator, default is [/].
  /// [querySeparator]: Query parameter, default is [?].
  static List<String> split(String path,
      {String separator = Const.slash,
      String querySeparator = Const.question}) {
    try {
      if (isEmpty(path)) return ListPool.get();
      if (path.contains(querySeparator)) {
        List<String> paths = path.split(querySeparator);
        path = paths.first;
        path = path?.trimString(separator);
        if (isEmpty(path)) return [paths.last];
        return path.split(separator).insertLast(paths.last);
      } else {
        path = path?.trimString(separator);
        if (isEmpty(path)) return ListPool.get();
        return path.split(separator);
      }
    } catch (e) {}
    return null;
  }

  /// Removes the query parameter, if any.
  ///
  /// [path]: Path to use.
  /// [querySeparator]: Query parameter, default is [?].
  static String removeQuery(String path,
      {String querySeparator = Const.question}) {
    try {
      if (isEmpty(path)) return path;
      if (!path.contains(querySeparator)) return path;
      return path.split(querySeparator).first;
    } catch (e) {}
    return null;
  }
}
