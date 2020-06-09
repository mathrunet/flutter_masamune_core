part of masamune.path;

/// List containing the path.
///
/// Save the path and use it later when doing [dispose()] all together.
class PathList with IterableMixin<IPath> {
  final List<FutureOr<IPath>> _data = ListPool.get();

  /// List containing the path.
  ///
  /// Save the path and use it later when doing [dispose()] all together.
  ///
  /// [path]: Path list to put first.
  PathList([Iterable<FutureOr<IPath>> path]) {
    if (path != null) this._data.addAll(path);
  }

  /// Add path.
  ///
  /// [path]: The path to add.
  PathList operator +(FutureOr<IPath> path) {
    this.add(path);
    return this;
  }

  /// Remove path.
  ///
  /// [path]: The path to remove.
  PathList operator -(FutureOr<IPath> path) {
    this.remove(path);
    return this;
  }

  /// Add path.
  ///
  /// [path]: The path to add.
  void add(FutureOr<IPath> path) => this._data.add(path);

  /// Remove path.
  ///
  /// [path]: The path to remove.
  void remove(FutureOr<IPath> path) => this._data.remove(path);

  /// Add paths together.
  ///
  /// [path]: The path to add.
  void addAll(Iterable<FutureOr<IPath>> paths) => this._data.addAll(paths);

  /// Used for turning in for statement.
  Iterator<IPath> get iterator => this._data.iterator;

  /// [dispose] paths together.
  void dispose() async {
    for (int i = this._data.length - 1; i >= 0; i--) {
      IPath tmp = await this._data[i];
      tmp?.dispose();
    }
    this._data.release();
  }
}
