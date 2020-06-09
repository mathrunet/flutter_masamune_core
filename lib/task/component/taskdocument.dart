part of masamune.task;

/// Document class with task management function.
///
/// The task performed is usually the [Future<T>] is returned.
///
/// Execution is completed when [isDone] becomes True.
///
/// If an error occurs, [isError] is True and the associated error flag is True.
///
/// Everything is built into the Path system and treated as a Document.
///
/// Please inherit and use.
abstract class TaskDocument<TChild extends IChild> extends Document<TChild>
    with TaskMixin
    implements ITask {
  /// Create a Completer that matches the class.
  /// Do not use from external class
  @protected
  Completer createCompleter() => Completer<Task>();

  /// Document class with task management function.
  ///
  /// The task performed is usually the [Future<T>] is returned.
  ///
  /// Execution is completed when [isDone] becomes True.
  ///
  /// If an error occurs, [isError] is True and the associated error flag is True.
  ///
  /// Everything is built into the Path system and treated as a Document.
  ///
  /// [path]: Document path.
  /// [children]: Initial document data, using TChild array.
  /// [isTemporary]: True if it is temporary data.
  /// [group]: Unit group (0 or more).
  /// [order]: Unit order.
  @protected
  TaskDocument(
      {String path,
      Iterable<TChild> children,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super(path,
            children: children,
            isTemporary: isTemporary,
            group: group,
            order: order) {
    this._completer = this.createCompleter();
  }
}
