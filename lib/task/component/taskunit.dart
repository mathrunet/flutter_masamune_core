part of masamune.task;

/// Abstract class for tasks.
///
/// The task performed is usually the [Future<T>] is returned.
///
/// Execution is completed when [isDone] becomes True.
///
/// If an error occurs, [isError] is True and the associated error flag is True.
///
/// Everything is built into the Path system and treated as a Unit.
///
/// Please inherit and use it.
abstract class TaskUnit<T extends Object> extends Unit<T>
    with TaskMixin
    implements ITask {
  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @protected
  Completer createCompleter();

  /// Abstract class for tasks.
  ///
  /// The task performed is usually the [Future<T>] is returned.
  ///
  /// Execution is completed when [isDone] becomes True.
  ///
  /// If an error occurs, [isError] is True and the associated error flag is True.
  ///
  /// Everything is built into the Path system and treated as a Unit.
  ///
  /// Please inherit and use it.
  ///
  /// [path]: Unit path.
  /// [value]: Unit value.
  /// [isTemporary]: True if it is temporary data.
  /// [group]: Unit group (0 or more).
  /// [order]: Unit order.
  @protected
  TaskUnit(
      {String path,
      dynamic value,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super(path,
            value: value,
            isTemporary: isTemporary,
            group: group,
            order: order) {
    this._completer = this.createCompleter();
  }
}
