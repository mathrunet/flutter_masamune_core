part of masamune.path;

/// Defines the path structure of the path system.
///
/// Same as URL or file system path.
///
/// The URL can be expressed as [https://mathru.net] and
/// the file path can be expressed as [/masamune/path].
///
/// This path class can use either expression.
class Path {
  static final RegExp _uriPattern = RegExp(
      r"^(([a-z0-9A-Z]+):/)?/?([^?#]+?(([^/?#]+?(\.([a-z]+))?))?)(\?([a-z0-9A-Z%&=:/+_-]+))?(#([a-z0-9A-Z_-]+))?$");

  /// Get URL.
  ///
  /// The URL is automatically updated when the element is updated.
  String get url {
    if (isNotEmpty(this._url)) return this._url;
    this._url = Const.empty;
    if (isNotEmpty(this.scheme)) this._url += this.scheme + "://";
    this._url += this.path;
    if (isNotEmpty(this.query)) this._url += "?" + this.query;
    if (isNotEmpty(this.anchor)) this._url += "#" + this.anchor;
    return this._url;
  }

  /// Set the URL.
  ///
  /// If the URL changes, the other elements will change accordingly.
  ///
  /// [value]: URL to change.
  set url(String value) {
    if (isEmpty(value)) {
      this._url = this.scheme = this.path =
          this.file = this.extension = this.query = this.anchor = null;
    } else {
      RegExpMatch match = _uriPattern.firstMatch(url);
      if (match != null) {
        this._url = url;
        this._scheme = match.group(2) ?? Const.empty;
        this._path = match.group(3) ?? Const.empty;
        this._file = isEmpty(this._path) ? Const.empty : Paths.last(this._path);
        this._extension = match.group(7) ?? Const.empty;
        this._query = match.group(9) ?? Const.empty;
        this._anchor = match.group(11) ?? Const.empty;
      } else {
        this._scheme = this._url = this._path =
            this._file = this._extension = this._query = this._anchor = null;
      }
    }
  }

  String _url;

  /// Get URL scheme.
  String get scheme => this._scheme;

  /// Set the URL scheme.
  ///
  /// If you change it, the URL will also change.
  ///
  /// [value]: Scheme to change.
  set scheme(String value) {
    this._url = null;
    this._scheme = value;
  }

  String _scheme;

  /// Get URL path.
  String get path => this._path;

  /// Set the URL path.
  ///
  /// If you change it, the URL will also change.
  ///
  /// [value]: Path to change.
  set path(String value) {
    this._url = null;
    this._path = value;
  }

  String _path;

  /// Get URL file / ID.
  String get file => this._file;

  /// Set the URL file / ID.
  ///
  /// If you change it, the URL will also change.
  ///
  /// [value]: File / ID to change.
  set file(String value) {
    this._url = null;
    this._file = value;
  }

  String _file;

  /// Get URL extension.
  String get extension => this._extension;

  /// Set the URL extension.
  ///
  /// If you change it, the URL will also change.
  ///
  /// [value]: Extension to change.
  set extension(String value) {
    this._url = null;
    this._extension = value;
  }

  String _extension;

  /// Get URL query.
  String get query => this._query;

  /// Set the URL query.
  ///
  /// If you change it, the URL will also change.
  ///
  /// [value]: Query to change.
  set query(String value) {
    this._url = null;
    this._query = value;
  }

  String _query;

  /// Get URL anchor.
  String get anchor => this._anchor;

  /// Set the URL anchor.
  ///
  /// If you change it, the URL will also change.
  ///
  /// [value]: Anchor to change.
  set anchor(String value) {
    this._url = null;
    this._anchor = value;
  }

  String _anchor;

  /// Defines the path structure of the path system.
  ///
  /// Same as URL or file system path.
  ///
  /// The URL can be expressed as [https://mathru.net] and
  /// the file path can be expressed as [/masamune/path].
  ///
  /// This path class can use either expression.
  ///
  /// [url]: URL to parse.
  Path([String url]) {
    if (isEmpty(url)) {
      this._scheme = this._url = this._path =
          this._file = this._extension = this._query = this._anchor = null;
    } else {
      RegExpMatch match = _uriPattern.firstMatch(url);
      if (match != null) {
        this._url = url;
        this._scheme = match.group(2) ?? Const.empty;
        this._path = match.group(3) ?? Const.empty;
        this._file = isEmpty(this._path) ? Const.empty : Paths.last(this._path);
        this._extension = match.group(7) ?? Const.empty;
        this._query = match.group(9) ?? Const.empty;
        this._anchor = match.group(11) ?? Const.empty;
      } else {
        this._scheme = this._url = this._path =
            this._file = this._extension = this._query = this._anchor = null;
      }
    }
  }

  /// Clone the path
  Path clone() {
    Path path = Path();
    path.scheme = this.scheme;
    path.path = this.path;
    path.file = this.file;
    path.extension = this.extension;
    path.query = this.query;
    path.anchor = this.anchor;
    return path;
  }
}
