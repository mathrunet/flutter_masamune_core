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
  static dynamic decode(String json) {
    assert(isNotEmpty(json));
    try {
      return jsonDecode(json);
    } catch (e) {
      Log.error(e.toString());
    }
    return null;
  }

  /// Json decoding.
  ///
  /// Only maps are output. If it is not a map, null is output.
  ///
  /// [json]: Json string.
  static Map<String, dynamic> decodeAsMap(String json) {
    assert(isNotEmpty(json));
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      Log.error(e.toString());
    }
    return null;
  }

  /// Json decoding.
  ///
  /// Only lists are output. If it is not a list, null is output.
  ///
  /// [json]: Json string.
  static List decodeAsList(String json) {
    assert(isNotEmpty(json));
    try {
      return jsonDecode(json) as List;
    } catch (e) {
      Log.error(e.toString());
    }
    return null;
  }

  /// Json encoding.
  ///
  /// Encode Map or List.
  ///
  /// [value]: The object to encode.
  static String encode(Object value) {
    assert(value != null);
    try {
      return jsonEncode(value);
    } catch (e) {
      Log.error(e.toString());
    }
    return null;
  }
}
