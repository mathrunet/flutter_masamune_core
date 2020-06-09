part of masamune.task;

/// Task queuing class.
///
/// Queued tasks are executed sequentially.
///
/// There is an upper limit. If it exceeds this, wait for the task to be executed.
///
/// ```
/// TaskQueue.enqueue( () => any task );
/// ```
class TaskQueue {
  static Timer _timer;
  static Queue<Future Function()> _queue = QueuePool.get();
  static List<Future> _now = ListPool.get();
  static void _startUpdate() {
    if (_timer != null) return;
    _timer = Timer.periodic(Config.periodicExecutionTime, (timer) {
      while (_queue.length > 0) {
        if (Config.taskQueueLimit >= _now.length) return;
        _run(_queue.removeFirst());
      }
    });
  }

  static void _run(Future task()) async {
    if (task == null) return;
    Future wait = task();
    if (wait == null) return;
    _now.add(wait);
    await wait;
    _now.remove(wait);
  }

  /// Queuing task.
  ///
  /// Queued tasks are executed sequentially.
  ///
  /// [task]: Queued tasks. Any method that returns [Future].
  static void enqueue(Future task()) {
    if (task == null || _queue.contains(task)) return;
    _startUpdate();
    _queue.addLast(task);
  }

  /// Check if the currently running task is full.
  ///
  /// True if task is full.
  static bool get isFull => _now.length >= Config.taskQueueLimit;

  /// Get task execution limit.
  static int get limitCount => Config.taskQueueLimit;

  /// Set task execution limit.
  ///
  /// [count]: Execution upper limit.
  static set limitCount(int count) => Config.taskQueueLimit = count;
}
