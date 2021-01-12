part of masamune.data;

/// Reads the data from the API and saves it as a collection format.
/// Basically, it is effective for APIs that have responses in map in list format in JSON.
///
/// You can be flexible with the response by specifying [builder].
class ApiCollection extends TaskCollection<RuntimeDocument>
    with SortableDataCollectionMixin<RuntimeDocument>
    implements IDataCollection<RuntimeDocument> {
  /// Endpoint url.
  String get url => this._url ?? this.path;
  String _url;

  /// Request body.
  String get requestBody => this._requestBody;
  String _requestBody;

  /// Post data.
  Map<String, String> get postData => this._postData;
  Map<String, String> _postData;

  /// Request header.
  Map<String, String> get headers => this._headers;
  Map<String, String> _headers;
  List<Map<String, dynamic>> Function(String response) _builder;

  /// Create a Completer that matches the class.
  /// Do not use from external class
  @override
  Completer createCompleter() => Completer<ApiDocument>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      ApiCollection._(
          path: path,
          isTemporary: isTemporary,
          url: this._url,
          requestBody: this._requestBody,
          postData: this._postData,
          headers: this._headers,
          builder: this._builder,
          orderBy: this.orderBy,
          orderByKey: this.orderByKey,
          thenBy: this.thenBy,
          thenByKey: this.thenByKey) as T;

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.https;

  /// Reads the data from the API and saves it as a document format.
  /// Basically, it is effective for APIs that have responses in map format in JSON.
  ///
  /// You can be flexible with the response by specifying [builder].
  ///
  /// [path]: Path of the document. If [url] is not specified, it is also used as URL.
  factory ApiCollection(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    ApiCollection collection = PathMap.get<ApiCollection>(path);
    if (collection != null) return collection;
    Log.warning(
        "No data was found from the pathmap. Please execute [listen()] first.");
    return null;
  }

  /// Reads the data from the API and saves it as a collection format.
  /// Basically, it is effective for APIs that have responses in map in list format in JSON.
  ///
  /// You can be flexible with the response by specifying [builder].
  ///
  /// [path]: Path of the document. If [url] is not specified, it is also used as URL.
  /// [url]: URL of the endpoint.
  /// [headers]: Request headers.
  /// [requestBody]: Request body.
  /// [postData]: Request post data.
  /// [builder]: Callback for constructing data from a response.
  /// [orderBy]: Sort order.
  /// [orderByKey]: Key for sorting.
  /// [thenBy]: Sort order when the first sort has the same value.
  /// [thenByKey]: Sort key when the first sort has the same value.
  static Future<ApiDocument> load(String path,
      {String url,
      Map<String, String> headers,
      String requestBody,
      Map<String, String> postData,
      List<Map<String, dynamic>> builder(String response),
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return Future.delayed(Duration.zero);
    }
    ApiCollection col = PathMap.get<ApiCollection>(path);
    if (col != null) {
      bool reload = false;
      if (col.isChanged(
          orderBy: orderBy,
          thenBy: thenBy,
          orderByKey: orderByKey,
          thenByKey: thenByKey)) reload = true;
      return reload ? col.reload() : col.future;
    }
    col = ApiCollection._(
        path: path,
        isTemporary: false,
        url: url,
        builder: builder,
        headers: headers,
        requestBody: requestBody,
        postData: postData);
    col._processInternal();
    return col.future;
  }

  /// Update document data.
  Future<T> reload<T extends IDataCollection>() {
    this._processInternal();
    return this.future;
  }

  ApiCollection._(
      {String path,
      bool isTemporary = false,
      String url,
      Map<String, String> headers,
      String requestBody,
      Map<String, String> postData,
      List<Map<String, dynamic>> builder(String response),
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : this._url = url,
        this._requestBody = requestBody,
        this._headers = headers,
        this._postData = postData,
        this._builder = builder,
        super(path: path, isTemporary: isTemporary) {
    this.orderBy = orderBy;
    this.orderByKey = orderByKey;
    this.thenBy = thenBy;
    this.thenByKey = thenByKey;
    if (this.length > 0) this.sort();
  }

  void _processInternal() async {
    try {
      this.init();
      if (this.requestBody != null) {
        final res = await http.post(this.url,
            body: this.requestBody, headers: this.headers);
        if (res.statusCode == 200) {
          _setInternal(res.body);
          this.done();
        } else {
          this.error(res.body);
        }
      } else if (this.postData != null) {
        final res = await http.post(this.url,
            body: this.postData, headers: this.headers);
        if (res.statusCode == 200) {
          _setInternal(res.body);
          this.done();
        } else {
          this.error(res.body);
        }
      } else {
        final res = await http.get(this.url, headers: this.headers);
        if (res.statusCode == 200) {
          _setInternal(res.body);
          this.done();
        } else {
          this.error(res.body);
        }
      }
    } catch (e) {
      this.error(e.toString());
    }
  }

  void _setInternal(String response) {
    if (isEmpty(response)) return;
    try {
      this.clear();
      dynamic json = this._builder != null
          ? this._builder(response)
          : jsonDecode(response);
      if (json is List<Map<String, dynamic>>) {
        for (Map<String, dynamic> tmp in json) {
          if (tmp == null) continue;
          RuntimeDocument doc =
              RuntimeDocument.fromMap(Paths.child(this.path, uuid), tmp);
          this.add(doc);
        }
      } else if (json is Map<String, Map<String, dynamic>>) {
        for (MapEntry<String, Map<String, dynamic>> tmp in json.entries) {
          if (isEmpty(tmp.key) || tmp.value == null) continue;
          RuntimeDocument doc = RuntimeDocument.fromMap(
              Paths.child(this.path, tmp.key), tmp.value);
          this.add(doc);
        }
      }
    } catch (e) {
      Log.error(e.toString());
    }
    this.sort();
    this.notifyUpdate();
  }
}
