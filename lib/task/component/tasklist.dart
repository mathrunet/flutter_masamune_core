part of masamune.task;

/// Keep your tasks together and wait later.
///
/// [Future.wait()] and [Future.any()] are wrapped, and you can use them,
/// but it is also easy to understand
/// because the process of creating [Iterable] is performed together.
///
/// ```
/// TaskList list = TaskList();
/// list += Task.waitFor( Duration(seconds:1) );
/// list += Task.waitFor( Duration(seconds:2) );
/// list += Task.waitFor( Duration(seconds:3) );
/// await list.waitAll();
/// ```
class TaskList<T extends ITask> extends TaskUnit with IterableMixin<Future<T>> {
  List<Future<T>> _data = ListPool.get();

  /// Iterator.
  ///
  /// Can be turned with for.
  @override
  Iterator<Future<T>> get iterator => this._data.iterator;

  /// Keep your tasks together and wait later.
  ///
  /// [Future.wait()] and [Future.any()] are wrapped, and you can use them,
  /// but it is also easy to understand
  /// because the process of creating [Iterable] is performed together.
  ///
  /// ```
  /// TaskList list = TaskList();
  /// list += Task.waitFor( Duration(seconds:1) );
  /// list += Task.waitFor( Duration(seconds:2) );
  /// list += Task.waitFor( Duration(seconds:3) );
  /// await list.waitAll();
  /// ```
  ///
  /// [tasks]: Task list to put in advance.
  TaskList([Iterable<Future<T>> tasks]) {
    if (tasks != null) this._data.addAll(tasks);
  }

  /// Add a new task.
  ///
  /// [task]: Task to add.
  TaskList<T> operator +(Future<T> task) {
    this.add(task);
    return this;
  }

  /// Remove a new task.
  ///
  /// [task]: Task to remove.
  TaskList<T> operator -(Future<T> task) {
    this.remove(task);
    return this;
  }

  /// Add a new task.
  ///
  /// [task]: Task to add.
  void add(Future<T> task) {
    if (task == null || this._data.contains(task)) return;
    this._data.add(task);
  }

  /// Add multiple tasks.
  ///
  /// [tasks]: Task to add.
  void addAll(Iterable<Future<T>> tasks) {
    if (tasks == null || tasks.length <= 0) return;
    for (Future<T> task in tasks) {
      if (this._data.contains(task)) continue;
      this._data.add(task);
    }
  }

  /// Remove a new task.
  ///
  /// [task]: Task to remove.
  void remove(Future<T> task) {
    if (task == null) return;
    this._data.remove(task);
  }

  /// Remove multiple tasks.
  ///
  /// [tasks]: Task to remove.
  void removeAll(Iterable<Future<T>> tasks) {
    if (tasks == null || tasks.length <= 0) return;
    for (Future<T> task in tasks) {
      this._data.remove(task);
    }
  }

  /// Wait for all tasks.
  ///
  /// Wrapping [Future.wait()].
  ///
  /// [tasks]: Task to execute (Future).
  /// [eagerError]: If eagerError is true,
  /// the returned future completes with an error immediately on the first error from one of the futures. Otherwise all futures must complete before the returned future is completed (still with the first error; the remaining errors are silently dropped).
  /// [cleanUp]: In the case of an error, [cleanUp] (if provided),
  /// is invoked on any non-null result of successful futures.
  /// This makes it possible to cleanUp resources that would otherwise be lost
  /// (since the returned future does not provide access to these values).
  /// The [cleanUp] function is unused if there is no error.
  Future<List<T>> waitAll(
      {Iterable<Future<T>> tasks,
      bool eagerError = false,
      void cleanUp(T success)}) {
    if (tasks != null && tasks.length > 0) this.addAll(tasks);
    return Future.wait<T>(this._data, eagerError: eagerError, cleanUp: cleanUp)
        .then((list) {
      this.done();
      return list;
    },
            onError: (e) => this
                .error("Processing terminated with an error" + e.toString()));
  }

  /// Wait for a task until one completes.
  ///
  /// Wrapping [Future.any()].
  ///
  /// [tasks]: Task to execute (Future).
  Future<T> waitAny({Iterable<Future<T>> tasks}) {
    if (tasks != null && tasks.length > 0) this.addAll(tasks);
    return Future.any<T>(this._data).then((t) {
      this.done();
      return t;
    },
        onError: (e) =>
            this.error("Processing terminated with an error" + e.toString()));
  }

  /// Exit as successful.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  @override
  @protected
  T done<T extends IDoable>() {
    super.done();
    return this as T;
  }

  /// Erminates processing with an error.
  ///
  /// You can use it publicly, but do not use it from outside the class.
  ///
  ///[message]: Error message.
  ///[errorLevel]: Set the error level.
  @override
  @protected
  T error<T extends IErrorable>(String message,
      {ErrorLevel errorLevel = ErrorLevel.error}) {
    super.error(message, errorLevel: errorLevel);
    return this as T;
  }

  /// Initialize all tasks.
  ///
  /// State is also initialized.
  void clear() {
    this.init();
    this._data.clear();
  }

  /// Create a Completer that matches the class.
  /// 
  /// Do not use from external class.
  @override
  Completer createCompleter() => Completer<TaskList>();

  @override
  T createInstance<T extends IClonable>(String path, bool isTemporary) => TaskList(
    this._data
  ) as T;

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.tmp;
}
