part of masamune.asset;

/// Get data from CSV and get it as a collection.
///
/// Get the columns as elements of the document and the rows into a collection.
class CSVCollection extends TaskCollection<DataDocument> {
  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      CSVCollection._(path: path, isTemporary: isTemporary) as T;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class
  @override
  Completer createCompleter() => Completer<CSVCollection>();

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.data;

  /// Get data from CSV and get it as a collection.
  ///
  /// Get the columns as elements of the document and the rows into a collection.
  ///
  /// [path]: CSV file path.
  factory CSVCollection(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    CSVCollection collection = PathMap.get<CSVCollection>(path);
    if (collection != null) return collection;
    Log.warning(
        "No data was found from the pathmap. Please execute [load()] first.");
    return null;
  }

  /// Get data from CSV and get it as a collection.
  ///
  /// Get the columns as elements of the document and the rows into a collection.
  ///
  /// [path]: CSV path.
  /// [offsetX]: Offset in the X direction of CSV.
  /// [offsetY]: Offset in the Y direction of CSV.
  /// [labels]: Document label.
  /// [timeout]: Timeout time.
  static Future<CSVCollection> load(String path,
      {int offsetX = 0,
      int offsetY = 0,
      List<String> labels = const [],
      Duration timeout = Const.timeout}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    assert(offsetX != null);
    assert(offsetY != null);
    assert(labels != null);
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    CSVCollection collection = PathMap.get<CSVCollection>(path);
    if (collection != null) return collection.future;
    collection = CSVCollection._(path: path);
    collection._loadProcess(
        offsetX: offsetX, offsetY: offsetY, labels: labels, timeout: timeout);
    return collection.future;
  }

  CSVCollection._({String path, bool isTemporary = false})
      : super(path: path, isTemporary: isTemporary, order: 10, group: 0);
  void _loadProcess(
      {int offsetX = 0,
      int offsetY = 0,
      List<String> labels = const [],
      Duration timeout = Const.timeout}) async {
    try {
      String csv = await rootBundle.loadString(path).timeout(timeout);
      if (csv == null || csv.length <= 0) {
        this.error("CSV data is empty.");
        return;
      }
      List<List> converted = const CsvToListConverter().convert(csv);
      if (converted.length <= offsetY || labels.length <= 0) {
        this.done();
        return;
      }
      for (int y = offsetY; y < converted.length; y++) {
        List line = converted[y];
        if (line == null) continue;
        if (line.length <= offsetX) continue;
        String id = line[offsetX].toString();
        if (isEmpty(id)) continue;
        DataDocument doc = DataDocument(Paths.child(this.path, id));
        for (int x = offsetX; x < line.length; x++) {
          int i = x - offsetX;
          if (i >= labels.length) continue;
          if (isEmpty(labels[i])) continue;
          doc[labels[i]] = line[x];
        }
        this.setInternal(doc);
      }
      this.done();
    } catch (e) {
      this.error(e.toString());
    }
  }
}
