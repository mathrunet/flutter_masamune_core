part of masamune.path;

/// Class to set path tag.
///
/// By setting a key, you can replace the path value in the form of [Key].
///
/// Use [set()] method for key setting.
class PathTag {
  static final RegExp _tagPattern = RegExp(r"(\[[^\]]+\])");
  static final Map<String, String> _builder = MapPool.get();

  /// Returns the path with a specific tag added and replaced.
  ///
  /// To set a specific value to the path, use the [set()] method.
  ///
  /// If the path is described as [key], it will be replaced with the value specified for key.
  ///
  /// [path]: The path to apply.
  static String apply(String path) {
    if (isEmpty(path)) return path;
    return path.replaceAllMapped(_tagPattern, (m) {
      String key = m.group(0);
      if (isEmpty(key) || !_builder.containsKey(key)) return Const.empty;
      return _builder[key];
    });
  }

  /// Set the key of the path to be replaced with [PathTag.apply()].
  ///
  /// [key]: Key to set.
  /// [value]: Value to set.
  static void set(String key, String value) {
    if (isEmpty(key) || isEmpty(value)) return;
    _builder[Const.bracketStart + key + Const.bracketEnd] = value;
  }
}

/// Path extension methods.
extension PathTabExtension on String {
  /// Returns the path with a specific tag added and replaced.
  ///
  /// To set a specific value to the path, use the [set()] method.
  ///
  /// If the path is described as [key], it will be replaced with the value specified for key.
  String applyTags() => PathTag.apply(this)
      ?.trimString(Const.slash)
      ?.replaceAll("//", "/")
      ?.replaceAll(":/", "://");
}
