import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test("Task/Task/Run Test", () async {
    var tester = TestLog();
    tester.set(1);
    await Task.waitFor(Duration(seconds: 1)).onSuccess((r) async {
      r.runtimeType.are(Task);
      tester.set(2);
      await Task.waitFor(Duration(seconds: 1));
      tester.set(3);
      return Task.waitFor(Duration(seconds: 1)).then((k) async {
        k.runtimeType.are(Task);
        tester.set(4);
        await Task.waitFor(Duration(seconds: 1));
        tester.set(5);
        return k;
      });
    }).then((r) async {
      r.runtimeType.are(Task);
      tester.set(6);
      await Task.waitFor(Duration(seconds: 1));
      tester.set(7);
      return Task.waitFor(Duration(seconds: 1));
    });
    tester.set(8);
    tester.result();
    TestLog.clear();
  });
  test("Task/Task/Callback Test", () async {
    var tester = TestLog();
    tester.set(1);
    await Task.waitFor(Duration(seconds: 1)).onDone((r) async {
      tester.set(2);
      await Task.waitFor(Duration(seconds: 2));
      tester.set(3);
      return Task.waitFor(Duration(seconds: 1)).onDone((k) async {
        tester.set(4);
        await Task.waitFor(Duration(seconds: 1));
        tester.set(5);
        await Task.waitFor(Duration(seconds: 1));
        tester.set(6);
        return k;
      }).onDone((k) async {
        tester.set(7);
        await Task.waitFor(Duration(seconds: 1));
        tester.set(8);
        return k;
      });
    });
    tester.set(9);
    await Task.waitFor(Duration(seconds: 1));
    tester.set(10);
    tester.result();
    PathMap.clear();
    PathFilter.clear();
    PathListener.clear();
  });
  test("Task/Task/State Test", () async {
    var tester = TestLog();
    tester.set(1);
    await Task.waitFor(Duration(seconds: 1)).onDone((r) {
      tester.set(2);
      return Task.waitFor(Duration(seconds: 1)).onDone((k) {
        tester.set(3);
        return k;
      });
    }).onDone((r) {
      tester.set(4);
      return Task.waitFor(Duration(seconds: 1)).onDone((k) {
        tester.set(5);
        return k;
      });
    });
    await Task.waitFor(Duration(seconds: 1));
    tester.result();
    PathMap.clear();
    PathFilter.clear();
    PathListener.clear();
  });
}
