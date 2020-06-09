part of masamune.task;

/// Extension method for task list.
extension ITaskListExtension<T extends ITask> on Iterable<T> {
  /// True when the object has finished executing.
  bool get isDone {
    for (T task in this) {
      if (task == null) continue;
      if (!task.isDone) return false;
    }
    return true;
  }

  /// True if the object was interrupted.
  bool get isAbort {
    for (T task in this) {
      if (task == null) continue;
      if (task.isAbort) return true;
    }
    return false;
  }

  /// True if the object is in error.
  bool get isError {
    for (T task in this) {
      if (task == null) continue;
      if (task.isError) return true;
    }
    return false;
  }

  /// True if the object has timed out.
  bool get isTimeout {
    for (T task in this) {
      if (task == null) continue;
      if (task.isTimeout) return true;
    }
    return false;
  }

  /// True if object or application is restricted.
  bool get isRestricted {
    for (T task in this) {
      if (task == null) continue;
      if (task.isRestricted) return true;
    }
    return false;
  }

  /// True if not connected to network.
  bool get isNotReachableNetwork {
    for (T task in this) {
      if (task == null) continue;
      if (task.isNotReachableNetwork) return true;
    }
    return false;
  }

  /// True when system is not supported.
  bool get isNotSupported {
    for (T task in this) {
      if (task == null) continue;
      if (task.isNotSupported) return true;
    }
    return false;
  }

  /// True if object or data not found.
  bool get isNotFound {
    for (T task in this) {
      if (task == null) continue;
      if (task.isNotFound) return true;
    }
    return false;
  }

  /// True if object or data is duplicated.
  bool get isDuplicate {
    for (T task in this) {
      if (task == null) continue;
      if (task.isDuplicate) return true;
    }
    return false;
  }

  /// Get error message.
  String get message {
    String tmp = Const.empty;
    for (T task in this) {
      if (task == null || isEmpty(task.message)) continue;
      tmp += task.message + "\n";
    }
    return tmp;
  }

  /// Gets the progress (0.0 - 1.0).
  double get progress {
    double total = 0;
    for (T task in this) {
      if (task == null) continue;
      total += task.progress;
    }
    return total / this.length;
  }
}

/// Extension method for asynchronous processing.
extension FutureITaskExtension<T extends ITask> on Future<T> {
  /// Callback executed when processing is completed.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task ends.
  Future<T> onDone(FutureOr<T> onValue(T task)) => this.then(onValue);

  /// Callback executed when processing is successful.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task is successful.
  Future<T> onSuccess(FutureOr<T> onValue(T task)) {
    return this.then((T task) async {
      if (!task.isDone || task.isError || task.isAbort) return task;
      return onValue(task);
    });
  }

  /// Callback executed when processing fails.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task fails.
  Future<T> onFailed(FutureOr<T> onValue(T task)) {
    return this.then((T task) async {
      if (!task.isDone || !task.isError) return task;
      return onValue(task);
    });
  }

  /// Callback executed when processing is timed out.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task is timed out.
  Future<T> onTimeout(FutureOr<T> onValue(T task)) {
    return this.then((T task) async {
      if (!task.isDone || !task.isError || !task.isTimeout) return task;
      return onValue(task);
    });
  }

  /// Callback executed when processing is interrupted.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task is interrupted.
  Future<T> onAborted(FutureOr<T> onValue(T task)) {
    return this.then((T task) async {
      if (!task.isDone || !task.isError || !task.isAbort) return task;
      return onValue(task);
    });
  }
}

/// Extension method for asynchronous processing.
extension FutureITaskListExtension<T extends ITask> on Future<List<T>> {
  /// Callback executed when processing is completed.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task ends.
  Future<List<T>> onDone(FutureOr<List<T>> onValue(List<T> task)) =>
      this.then(onValue);

  /// Callback executed when processing is successful.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task is successful.
  Future<List<T>> onSuccess(FutureOr<List<T>> onValue(List<T> task)) {
    return this.then((List<T> tasks) async {
      for (T task in tasks) {
        if (!task.isDone || task.isError || task.isAbort) return tasks;
      }
      return onValue(tasks);
    });
  }

  /// Callback executed when processing fails.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task fails.
  Future<List<T>> onFailed(FutureOr<List<T>> onValue(List<T> task)) {
    return this.then((List<T> tasks) async {
      for (T task in tasks) {
        if (!task.isDone) return tasks;
        if (task.isError) return onValue(tasks);
      }
      return tasks;
    });
  }

  /// Callback executed when processing is timed out.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task is timed out.
  Future<List<T>> onTimeout(FutureOr<List<T>> onValue(List<T> task)) {
    return this.then((List<T> tasks) async {
      for (T task in tasks) {
        if (!task.isDone) return tasks;
        if (task.isError && task.isTimeout) return onValue(tasks);
      }
      return tasks;
    });
  }

  /// Callback executed when processing is interrupted.
  ///
  /// Wrapping [then()].
  ///
  /// [onValue]: Callback executed when task is interrupted.
  Future<List<T>> onAborted(FutureOr<List<T>> onValue(List<T> task)) {
    return this.then((List<T> tasks) async {
      for (T task in tasks) {
        if (!task.isDone) return tasks;
        if (task.isAbort) return onValue(tasks);
      }
      return tasks;
    });
  }
}
