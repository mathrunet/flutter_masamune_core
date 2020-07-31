part of masamune.dartcore;

/// Object extension methods.
extension ObjectExtension on Object {
  /// Returns as a string.
  String get asString => this as String;

  /// Returns as a int.
  int get asInt => this as int;

  /// Returns as a double.
  double get asDouble => this as double;

  /// Returns as a bool.
  bool get asBool => this as bool;

  /// Cast to a specific type.
  T asType<T extends Object>() => this as T;

  /// Convert the contents as Future.
  Future<T> asFuture<T extends Object>() {
    return Future.delayed(Duration.zero, () => this);
  }
}

/// String extension methods.
extension StringExtension on String {
  /// Trim with specific characters.
  ///
  /// [chars]: The string to trim.
  String trimString(String chars) {
    RegExp pattern = (chars != null)
        ? RegExp("^[$chars]+|[$chars]+\$")
        : RegExp(r'^\s+|\s+$');
    return this.replaceAll(pattern, '');
  }

  /// Trim only the left side with a specific string.
  ///
  /// [chars]: The string to trim.
  String trimStringLeft(String chars) {
    RegExp pattern = (chars != null) ? RegExp("^[$chars]+") : RegExp(r'^\s+');
    return this.replaceAll(pattern, '');
  }

  /// Trim only the right side with a specific string.
  ///
  /// [chars]: The string to trim.
  String trimStringRight(String chars) {
    RegExp pattern = (chars != null) ? RegExp("[$chars]+\$") : RegExp(r'\s+$');
    return this.replaceAll(pattern, '');
  }

  /// Converts a String to an int.
  ///
  /// Normally it parses, but if it cannot parse it, it creates a random string.
  int toInt() {
    if (isEmpty(this)) return 0;
    int i = int.tryParse(this);
    if (i != null) return i;
    int val = 0;
    for (int rune in this.runes) {
      val += (val + 1) * rune;
    }
    return val;
  }

  /// Converts a String to an int.
  ///
  /// Normally it parses, but if it cannot parse it, it creates a random string.
  double toDouble() {
    if (isEmpty(this)) return 0;
    double d = double.tryParse(this);
    if (d != null) return d;
    double val = 0;
    for (int rune in this.runes) {
      val += (val + 1) * rune;
    }
    return val;
  }

  /// Parses a String into a bool.
  bool toBool() {
    if (this.toLowerCase() == "true") return true;
    return false;
  }

  /// Encoded in Base64.
  String toBase64() => utf8.fuse(base64).encode(this);

  /// Decoded in Base64.
  String fromBase64() => utf8.fuse(base64).decode(this);

  /// Convert to SHA1 hash.
  String toSHA1() => sha1.convert(utf8.encode(this)).toString();

  /// Convert to SHA256 hash.
  ///
  /// [password]: Password.
  String toSHA256(String password) {
    if (isEmpty(password)) return this;
    Hmac hmacSha256 = Hmac(sha256, utf8.encode(password));
    return hmacSha256.convert(utf8.encode(this)).toString();
  }
}

/// Random extension methods.
extension RandomExtension on Random {
  /// Get a random number from [min] to [max].
  ///
  /// [min]: Minimum value.
  /// [max]: Maximum value.
  int rangeInt(int min, int max) =>
      ((this.nextDouble() * (max - min)) + min).toInt().limit(min, max);

  /// Get a random number from [min] to [max].
  ///
  /// [min]: Minimum value.
  /// [max]: Maximum value.
  double rangeDouble(double min, double max) =>
      ((this.nextDouble() * (max - min)) + min).limit(min, max);
}

/// Int extension methods.
extension IntExtention on int {
  /// Restrict value from [min] to [max].
  ///
  /// [min]: Minimum value.
  /// [max]: Maximum value.
  int limit(int min, int max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Restrict value from [min].
  ///
  /// [min]: Minimum value.
  int limitLow(int min) {
    if (this < min) return min;
    return this;
  }

  /// Restrict value from [max].
  ///
  /// [max]: Maximum value.
  int limitHigh(int max) {
    if (this > max) return max;
    return this;
  }

  /// Represents a number in format.
  ///
  /// The format depends on NumberFormat.
  ///
  /// [format]: Number format.
  String format(String format) {
    if (isEmpty(format)) return Const.empty;
    return NumberFormat(format).format(this);
  }
}

/// Double extension methods.
extension DoubleExtention on double {
  /// Restrict value from [min] to [max].
  ///
  /// [min]: Minimum value.
  /// [max]: Maximum value.
  double limit(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Restrict value from [min].
  ///
  /// [min]: Minimum value.
  double limitLow(double min) {
    if (this < min) return min;
    return this;
  }

  /// Restrict value from [max].
  ///
  /// [max]: Maximum value.
  double limitHigh(double max) {
    if (this > max) return max;
    return this;
  }

  /// Represents a number in format.
  ///
  /// The format depends on NumberFormat.
  ///
  /// [format]: Number format.
  String format(String format) {
    if (isEmpty(format)) return Const.empty;
    return NumberFormat(format).format(this);
  }
}

/// Bool extension methods.
extension BoolExtension on bool {
  /// Compares two values.
  ///
  /// [bool]: Other values.
  int compareTo(bool other) {
    if (this == other) return 0;
    if (this == true) return 1;
    if (other == true) return -1;
    return 0;
  }
}

/// DateTime extension methods.
extension DateTimeExtension on DateTime {
  /// Gets the time per frame in UnixTime in milliseconds.
  int get frameMillisecondsSinceEpoch =>
      (this.millisecondsSinceEpoch / 30).round() * 30;

  /// True if the specified time or the current time is the same day.
  ///
  /// [dateTime]: Time to compare.
  bool isToday([DateTime dateTime]) {
    if (dateTime == null) dateTime = DateTime.now();
    return this.year == dateTime.year &&
        this.month == dateTime.month &&
        this.day == dateTime.day;
  }

  /// True if the specified time or the current time is the same month.
  ///
  /// [dateTime]: Time to compare.
  bool isThisMonth([DateTime dateTime]) {
    if (dateTime == null) dateTime = DateTime.now();
    return this.year == dateTime.year && this.month == dateTime.month;
  }

  /// True if the specified time or the current time is the same year.
  ///
  /// [dateTime]: Time to compare.
  bool isThisYear([DateTime dateTime]) {
    if (dateTime == null) dateTime = DateTime.now();
    return this.year == dateTime.year;
  }

  /// True if the specified time or the current time is the same hour.
  ///
  /// [dateTime]: Time to compare.
  bool isThisHour([DateTime dateTime]) {
    if (dateTime == null) dateTime = DateTime.now();
    return this.year == dateTime.year &&
        this.month == dateTime.month &&
        this.day == dateTime.day &&
        this.hour == dateTime.hour;
  }

  /// True if the specified time or the current time is the same minute.
  ///
  /// [dateTime]: Time to compare.
  bool isThisMimute([DateTime dateTime]) {
    if (dateTime == null) dateTime = DateTime.now();
    return this.year == dateTime.year &&
        this.month == dateTime.month &&
        this.day == dateTime.day &&
        this.hour == dateTime.hour &&
        this.minute == dateTime.minute;
  }

  /// True if the specified time or the current time is the same second.
  ///
  /// [dateTime]: Time to compare.
  bool isThisSecond([DateTime dateTime]) {
    if (dateTime == null) dateTime = DateTime.now();
    return this.year == dateTime.year &&
        this.month == dateTime.month &&
        this.day == dateTime.day &&
        this.hour == dateTime.hour &&
        this.minute == dateTime.minute &&
        this.second == dateTime.second;
  }
}

/// Future extension methods
extension FutureExtension on Future {
  /// Check if this Future has finished.
  ///
  /// True if finished.
  bool get isCompleted {
    bool isCompleted = false;
    this.whenComplete(() => isCompleted = true);
    return isCompleted;
  }
}

/// Iterable future extension methods.
extension IterableFutureExtension<T extends Object> on Iterable<Future<T>> {
  /// Gives and returns processing to the Future list.
  ///
  /// Wait for all asynchronous processing and return the result as a list.
  ///
  /// [function]: Callback function that gives processing.
  Stream<T> mapAsync([T function(T source)]) async* {
    for (Future<T> o in this)
      yield function != null ? function(await o) : await o;
  }
}

/// Iterable extension methods.
extension IterableExtension<T extends Object> on Iterable<T> {
  /// After replacing the data in the list, delete the null.
  ///
  /// [callback]: Callback function used in map.
  List<TCast> mapAndRemoveEmpty<TCast extends Object>(TCast callback(T item)) {
    List<TCast> list = this?.map<TCast>(callback)?.toList();
    if (list == null) return ListPool.get();
    list.removeWhere((tmp) => tmp == null);
    return list;
  }

  /// If the iterator value is empty, delete the element.
  List<T> removeEmpty() {
    List<T> list = this?.toList();
    if (list == null) return ListPool.get();
    list.removeWhere((tmp) => tmp == null);
    return list;
  }

  /// Convert the contents as Future.
  Iterable<Future<T>> asIterableFuture() {
    return this
        ?.map<Future<T>>((tmp) => Future.delayed(Duration.zero, () => tmp));
  }

  /// Divides the array by the specified number into an array.
  ///
  /// [length]: The number to divide.
  Iterable<Iterable<T>> split(int length) {
    length = length.limit(0, this.length);
    List<T> tmp;
    List<Iterable<T>> res = ListPool.get();
    if (length == 0) return res;
    int i = 0;
    for (T item in this) {
      if (i % length == 0) {
        if (tmp != null) res.add(tmp);
        tmp = ListPool.get();
      }
      tmp.add(item);
      i++;
    }
    if (tmp != null) res.add(tmp);
    return res;
  }

  /// Takes out the first element.
  ///
  /// If there is no element, return null instead of Exception.
  T get firstOrNull {
    if (this.length <= 0) return null;
    return this.first;
  }

  /// Takes out the last element.
  ///
  /// If there is no element, return null instead of Exception.
  T get lastOrNull {
    if (this.length <= 0) return null;
    return this.last;
  }

  /// Method indexed forEach.
  ///
  /// The [index] starts at 0 and is incremented by 1.
  ///
  /// [function]: Action to be performed
  void forEachIndex(void function(T value, int index)) {
    int i = 0;
    for (T value in this) {
      function(value, i);
      i++;
    }
  }

  /// Converts the list into a map.
  ///
  /// [key]: Callback to get the key from the element.
  /// [value]: Callback to get the value from the element.
  Map<K, V> toMap<K extends Object, V extends Object>(
      {K key(T e), V value(T e)}) {
    return Map.fromIterable(this, key: key, value: value);
  }
}

/// List extension methods.
extension ListExtension<T extends Object> on List<T> {
  /// Insert the element first.
  ///
  /// [element]: The element to insert.
  List<T> insertFirst(T element) {
    if (element == null) return this;
    this.insert(0, element);
    return this;
  }

  /// Insert the element last.
  ///
  /// [element]: The element to insert.
  List<T> insertLast(T element) {
    if (element == null) return this;
    this.add(element);
    return this;
  }

  /// Inserts an element at the element's position if True with a test.
  ///
  /// [insert]: The element to insert.
  /// [test]: The method to test.
  List<T> insertWhere(T insert, bool test(T prev, T current, T next)) {
    for (int i = this.length - 1; i >= 0; i--) {
      if (!test(i <= 0 ? null : this[i - 1], this[i],
          i >= this.length - 1 ? null : this[i + 1])) continue;
      this.insert(i, insert);
      return this;
    }
    this.insert(0, insert);
    return this;
  }
}

/// Map extension methods.
extension StringMapExtension on Map<String, dynamic> {
  /// Reads data from a tree-structured map using paths.
  ///
  /// If there is no data, null is returned.
  ///
  /// [path]: The data path to read.
  dynamic readFromPath(String path) {
    if (isEmpty(path)) return null;
    List<String> paths = Paths.split(path);
    if (paths == null || paths.length <= 0) return null;
    return this._readFromPathInternal(paths, 0);
  }

  dynamic _readFromPathInternal(List<String> paths, int index) {
    if (paths.length <= index) return this;
    String p = paths[index];
    if (isEmpty(p) || !this.containsKey(p)) return null;
    if (this[p] is Map<String, dynamic>)
      return (this[p] as Map<String, dynamic>)
          ._readFromPathInternal(paths, index + 1);
    return this[p];
  }

  /// Writes data to the tree structure map.
  ///
  /// A map will be created even if there is no intermediate tree.
  ///
  /// [path]: The path of data to write.
  /// [value]: The data to write.
  void writeToPath(String path, dynamic value) {
    if (isEmpty(path)) return;
    List<String> paths = Paths.split(path);
    if (paths == null || paths.length <= 0) return;
    this._writeToPathInternal(paths, 0, value);
  }

  void _writeToPathInternal(List<String> paths, int index, dynamic value) {
    if (paths.length - 1 <= index) {
      this.remove(paths[index]);
      this[paths[index]] = value;
      return;
    }
    String p = paths[index];
    if (isEmpty(p)) return;
    if (!this.containsKey(p) ||
        this[p] == null ||
        !(this[p] is Map<String, dynamic>)) {
      this[p] = MapPool.get<String, dynamic>();
    }
    (this[p] as Map<String, dynamic>)
        ._writeToPathInternal(paths, index + 1, value);
  }

  /// Deletes the data of the specified path from the tree structure data.
  ///
  /// All data under that path will be deleted.
  ///
  /// [path]: The path of data to delete.
  void deleteFromPath(String path) {
    if (isEmpty(path)) return;
    List<String> paths = Paths.split(path);
    if (paths == null || paths.length <= 0) return;
    this._deleteFromPathInternal(paths, 0);
  }

  void _deleteFromPathInternal(List<String> paths, int index) {
    if (paths.length - 1 <= index) {
      this.remove(paths[index]);
      return;
    }
    String p = paths[index];
    if (isEmpty(p)) return;
    if (!this.containsKey(p) ||
        this[p] == null ||
        !(this[p] is Map<String, dynamic>)) {
      return;
    }
    (this[p] as Map<String, dynamic>)._deleteFromPathInternal(paths, index + 1);
  }
}
