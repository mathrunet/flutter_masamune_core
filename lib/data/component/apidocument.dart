part of masamune.data;

/// Reads the data from the API and saves it as a document format.
/// Basically, it is effective for APIs that have responses in map format in JSON.
///
/// You can be flexible with the response by specifying [builder].
class ApiDocument extends TaskDocument<DataField>
    with DataDocumentMixin<DataField>
    implements IDataDocument<DataField> {
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
  Map<String, dynamic> Function(String response) _builder;

  /// Create a Completer that matches the class.
  /// Do not use from external class
  @override
  Completer createCompleter() => Completer<ApiDocument>();

  /// package:masamune_core/data/data.dart
  ///
  /// Create a new field.
  ///
  /// [path]: Field path.
  /// [value]: Field value.
  @override
  DataField createField([String path, value]) => DataField(path, value);

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      ApiDocument._(
          path: path,
          isTemporary: isTemporary,
          url: this._url,
          requestBody: this._requestBody,
          postData: this._postData,
          headers: this._headers,
          builder: this._builder) as T;

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.https;

  /// Reads the data from the API and saves it as a document format.
  /// Basically, it is effective for APIs that have responses in map format in JSON.
  ///
  /// You can be flexible with the response by specifying [builder].
  ///
  /// [path]: Path of the document. If [url] is not specified, it is also used as URL.
  factory ApiDocument(String path) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    ApiDocument document = PathMap.get<ApiDocument>(path);
    if (document != null) return document;
    Log.warning(
        "No data was found from the pathmap. Please execute [listen()] first.");
    return null;
  }

  /// Reads the data from the API and saves it as a document format.
  /// Basically, it is effective for APIs that have responses in map format in JSON.
  ///
  /// You can be flexible with the response by specifying [builder].
  ///
  /// [path]: Path of the document. If [url] is not specified, it is also used as URL.
  /// [url]: URL of the endpoint.
  /// [headers]: Request headers.
  /// [requestBody]: Request body.
  /// [postData]: Request post data.
  /// [builder]: Callback for constructing data from a response.
  static Future<ApiDocument> load(String path,
      {String url,
      Map<String, String> headers,
      String requestBody,
      Map<String, String> postData,
      Map<String, dynamic> builder(String response)}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return Future.delayed(Duration.zero);
    }
    ApiDocument doc = PathMap.get<ApiDocument>(path);
    if (doc != null) return doc.reload();
    doc = ApiDocument._(
        path: path,
        isTemporary: false,
        url: url,
        builder: builder,
        headers: headers,
        requestBody: requestBody,
        postData: postData);
    doc._processInternal();
    return doc.future;
  }

  /// Update document data.
  Future<T> reload<T extends IDataDocument>() {
    this._processInternal();
    return this.future;
  }

  ApiDocument._(
      {String path,
      bool isTemporary = false,
      String url,
      Map<String, String> headers,
      String requestBody,
      Map<String, String> postData,
      Map<String, dynamic> builder(String response)})
      : this._url = url,
        this._requestBody = requestBody,
        this._headers = headers,
        this._postData = postData,
        this._builder = builder,
        super(path: path, isTemporary: isTemporary);

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
      Map<String, dynamic> json = this._builder != null
          ? this._builder(response)
          : jsonDecode(response);
      for (MapEntry<String, dynamic> tmp in json.entries) {
        if (isEmpty(tmp.key) || tmp.value == null) continue;
        this[tmp.key] = tmp.value;
      }
    } catch (e) {
      Log.error(e.toString());
    }
    this.notifyUpdate();
  }
}
