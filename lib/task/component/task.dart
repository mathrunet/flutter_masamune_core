part of masamune.task;

/// Perform the task.
///
/// The task performed is usually the [Future<T>] is returned.
///
/// Execution is completed when [isDone] becomes True.
///
/// If an error occurs, [isError] is True and the associated error flag is True.
///
/// Everything is built into the Path system and treated as a Unit.
class Task<T extends Object> extends TaskUnit<T> {
  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @protected
  Completer createCompleter() => Completer<Task>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) => Task(
      path: path,
      isTemporary: isTemporary,
      order: this.order,
      group: this.group) as T;

  /// Perform the task.
  ///
  /// The task performed is usually the [Future<T>] is returned.
  ///
  /// Execution is completed when [isDone] becomes True.
  ///
  /// If an error occurs, [isError] is True and the associated error flag is True.
  ///
  /// Everything is built into the Path system and treated as a Unit.
  ///
  /// Wait for the specified interval.
  ///
  /// Wrapping [Future.delayed(duration)].
  ///
  /// [time]: Duration time
  static Future<Task> waitFor(Duration time) {
    Task task = Task();
    task._waitFor(time);
    return task.future;
  }

  void _waitFor(Duration time) async {
    await Future.delayed(time);
    this.done();
  }

  /// Create a task based on the conditions.
  ///
  /// [callback] is True, the process ends.
  ///
  /// [callback]: The process to perform.
  /// [timeout]: Timeout time.
  static Future<Task> waitWhere(bool callback(),
      {Duration timeout = const Duration(seconds: 5)}) async {
    Task task = Task();
    if (callback == null) {
      task.done();
      return task.future;
    }
    if (timeout == null) {
      await task._waitWhere(callback);
    } else {
      await Future.any([Future.delayed(timeout), task._waitWhere(callback)]);
    }
    task.done();
    return task.future;
  }

  Future _waitWhere(bool callback()) async {
    while (!this.isDone && !callback()) {
      await Future.delayed(Config.frameTime);
    }
  }

  /// Perform the task.
  ///
  /// The task performed is usually the [Future<T>] is returned.
  ///
  /// Execution is completed when [isDone] becomes True.
  ///
  /// If an error occurs, [isError] is True and the associated error flag is True.
  ///
  /// Everything is built into the Path system and treated as a Unit.
  ///
  /// [path]: Unit path.
  /// [value]: Unit value.
  /// [isTemporary]: True if it is temporary data.
  /// [group]: Unit group (0 or more).
  /// [order]: Unit order.
  @protected
  Task(
      {String path,
      dynamic value,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super(path:path,
            value: value,
            isTemporary: isTemporary,
            group: group,
            order: order) {
    this._completer = this.createCompleter();
  }

  

  /// Wait for all tasks.
  ///
  /// Wrapping [Future.wait()].
  ///
  /// [tasks]: Task to execute (Future).
  /// [eagerError]: If eagerError is true,
  /// the returned future completes with an error immediately on the first error from one of the futures.
  /// Otherwise all futures must complete before the returned future is completed
  /// (still with the first error; the remaining errors are silently dropped).
  /// [cleanUp]: In the case of an error, [cleanUp] (if provided),
  /// is invoked on any non-null result of successful futures.
  /// This makes it possible to cleanUp resources that would otherwise be lost
  /// (since the returned future does not provide access to these values).
  /// The [cleanUp] function is unused if there is no error.
  static Future<List<T>> waitAll<T extends ITask>(Iterable<Future<T>> tasks,
          {bool eagerError = false, void cleanUp(T success)}) =>
      Future.wait<T>(tasks, eagerError: eagerError, cleanUp: cleanUp);

  /// Wait for a task until one completes.
  ///
  /// Wrapping [Future.any()].
  ///
  /// [tasks]: Task to execute (Future).
  static Future<T> waitAny<T extends ITask>(Iterable<Future<T>> tasks) =>
      Future.any<T>(tasks);

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.tmp;
}
