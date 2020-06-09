import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test("Task/TaskList/Run Test", () async {
    var tester = TestLog();
    TaskList tasks = TaskList();
    tester.set(1);
    tasks += Task.waitFor(Duration(seconds: 1));
    tasks += Task.waitFor(Duration(seconds: 2));
    tasks += Task.waitFor(Duration(seconds: 3));
    tester.set(2);
    await tasks.waitAll();
    tester.set(3);
    tasks.clear();
    tasks += Task.waitFor(Duration(seconds: 1));
    tasks += Task.waitFor(Duration(seconds: 2));
    tasks += Task.waitFor(Duration(seconds: 3));
    tester.set(4);
    await tasks.waitAny();
    tester.set(5);
    tester.result();
    PathMap.clear();
    PathFilter.clear();
    PathListener.clear();
  });
}
