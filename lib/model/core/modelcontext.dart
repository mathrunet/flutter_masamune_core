part of masamune.model;

/// Context for building a model.
///
/// Basically, you get the path you entered and so on.
class ModelContext {
  final Model _model;
  final List<String> _listenerList = ListPool.get();
  ModelContext._(Model model) : this._model = model;

  /// Monitors the model for updates.
  ///
  /// [model]: Models to monitor.
  T watch<T extends IPath>(T model) {
    if (isEmpty(model?.path) || this._listenerList.contains(model.path))
      return model;
    model.watch(this._handledModelChanged);
    this._listenerList.add(model.path);
    return model;
  }

  void _handledModelChanged(IPath path) {
    this._model.rebuild();
  }

  void _dispose() {
    for (int i = this._listenerList.length - 1; i >= 0; i--) {
      PathListener.unwatch(this._listenerList[i], this._handledModelChanged);
    }
    this._listenerList.release();
  }
}
