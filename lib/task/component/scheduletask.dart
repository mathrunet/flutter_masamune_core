part of masamune.task;

/// Schedule at regular intervals and execute processing accordingly.
///
/// Since it is registered in the path map, it is unique and easy to cancel.
class ScheduleTask extends TaskUnit<Function> {
  Timer _timer;

  /// Schedule interval.
  final Duration duration;

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  Completer createCompleter() => Completer<ScheduleTask>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      ScheduleTask._(path: this.path, isTemporary: this.isTemporary) as T;

  /// Get the protocol of the path.
  @override
  String get protocol => Protocol.system;

  /// Schedule at regular intervals and execute processing accordingly.
  ///
  /// Since it is registered in the path map, it is unique and easy to cancel.
  ///
  /// [path]: The path to register.
  /// [interval]: The interval at which processing is performed.
  /// [task]: The task to perform.
  factory ScheduleTask(String path,
      {@required Duration interval, @required Function task}) {
    path = path?.applyTags();
    assert(isNotEmpty(path));
    assert(interval != null);
    assert(task != null);
    if (isEmpty(path)) {
      Log.error("The path is invalid.");
      return null;
    }
    if (interval == null) {
      Log.error("The interval is invalid.");
      return null;
    }
    if (task == null) {
      Log.error("The task is invalid.");
      return null;
    }
    ScheduleTask unit = PathMap.get<ScheduleTask>(path);
    if (unit != null) {
      if (task != null) unit.data = task;
      unit._startTimer();
      return unit;
    }
    unit = ScheduleTask._(path: path, interval: interval, task: task);
    unit._startTimer();
    return unit;
  }

  ScheduleTask._(
      {String path, Duration interval, Function task, bool isTemporary = false})
      : this.duration = interval,
        super(path: path, isTemporary: isTemporary, value: task);

  void _startTimer() {
    if (this._timer != null) return;
    this._timer = Timer.periodic(this.duration, (timer) {
      if (this.data == null) return;
      this.data();
    });
  }

  /// Destroys the object.
  ///
  /// Destroyed objects are not allowed.
  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    this._timer?.cancel();
    this._timer = null;
  }
}
