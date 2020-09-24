part of masamune.dartcore;

/// Json converter.
///
/// Extension of [dart:convert].
///
/// ```
/// String json = Json.encode( {"key": "value"} );
/// Map map = Json.decodeAsMap( json );
/// ```
class Json {
  /// Normal Json decoding.
  ///
  /// List or Map is output.
  ///
  /// [json]: Json string.
  /// [defaultValue]: Default value.
  static dynamic decode(String json, [dynamic defaultValue]) {
    try {
      return jsonDecode(json);
    } catch (e) {
      Log.error(e.toString());
    }
    return defaultValue;
  }

  /// Json decoding.
  ///
  /// Only maps are output. If it is not a map, null is output.
  ///
  /// [json]: Json string.
  /// [defaultValue]: Default value.
  static Map<String, T> decodeAsMap<T extends Object>(String json,
      [Map<String, T> defaultValue]) {
    try {
      return (jsonDecode(json) as Map<String, dynamic>).cast<String, T>();
    } catch (e) {
      Log.error(e.toString());
    }
    return defaultValue ?? <String, T>{};
  }

  /// Json decoding.
  ///
  /// Only lists are output. If it is not a list, null is output.
  ///
  /// [json]: Json string.
  /// [defaultValue]: Default value.
  static List<T> decodeAsList<T extends Object>(String json,
      [List<T> defaultValue]) {
    try {
      return (jsonDecode(json) as List).cast<T>();
    } catch (e) {
      Log.error(e.toString());
    }
    return defaultValue ?? <T>[];
  }

  /// Json encoding.
  ///
  /// Encode Map or List.
  ///
  /// [value]: The object to encode.
  /// [defaultValue]: Default value.
  static String encode(Object value, [String defaultValue = ""]) {
    try {
      return jsonEncode(value);
    } catch (e) {
      Log.error(e.toString());
    }
    return defaultValue;
  }
}
