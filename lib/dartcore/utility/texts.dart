part of masamune.dartcore;

/// Text-related utility classes.
class Texts {
  static const String _passwordChars =
      "23456789abcdefghjkmnpqrstuvwxyABCDEFGHJKLMNPQRSTUVWXYZ";
  static const String _passwordCharsForID = "23456789abcdefghjkmnpqrstuvwxy";

  /// Get UUID.
  ///
  /// A 32-byte string without hyphens is output.
  static String get uuid {
    Uuid uuid = Uuid();
    return uuid.v4().replaceAll("-", Const.empty);
  }

  /// Create a code of length [length] randomly.
  ///
  /// [seed] can be specified.
  ///
  /// [length]: Cord length.
  /// [seed]: Seed number.
  static String code(int length, {int seed = 0}) {
    int _length = _passwordChars.length;
    Random rand = seed != 0 ? Random(seed) : Random();
    List<int> codeUnits = List.generate(
      length,
      (index) {
        final n = rand.nextInt(_length);
        return _passwordChars.codeUnitAt(n);
      },
    );
    return new String.fromCharCodes(codeUnits);
  }

  /// Create a code of length [length] randomly for id.
  ///
  /// Characters that are difficult to understand are omitted.
  ///
  /// [seed] can be specified.
  ///
  /// [length]: Cord length.
  /// [seed]: Seed number.
  static String id(int length, {int seed = 0}) {
    int _length = _passwordCharsForID.length;
    Random rand = seed != 0 ? Random(seed) : Random();
    List<int> codeUnits = List.generate(
      length,
      (index) {
        final n = rand.nextInt(_length);
        return _passwordCharsForID.codeUnitAt(n);
      },
    );
    return new String.fromCharCodes(codeUnits);
  }

  /// Formats and displays text.
  ///
  /// Same type as PHP.
  static String format(String format, [List args]) => sprintf(format, args);

  /// Splits the text using the bigram algorithm.
  ///
  /// It is used for searching.
  ///
  /// [text]: Text to split.
  static List<String> bigram(String text) {
    if (isEmpty(text)) return ListPool.get();
    if (text.length <= 2) return [text];
    List<String> tmp = ListPool.get();
    for (int i = 0; i < text.length - 1; i++) {
      tmp.add(text.substring(i, min(i + 2, text.length)));
    }
    return tmp;
  }

  /// Splits the text using the trigram algorithm.
  ///
  /// It is used for searching.
  ///
  /// [text]: Text to split.
  static List<String> trigram(String text) {
    if (isEmpty(text)) return ListPool.get();
    if (text.length <= 3) return [text];
    List<String> tmp = ListPool.get();
    for (int i = 0; i < text.length - 2; i++) {
      tmp.add(text.substring(i, min(i + 3, text.length)));
    }
    return tmp;
  }
}
