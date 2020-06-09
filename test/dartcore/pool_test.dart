import 'dart:collection';
import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test('Pool/List Test', () {
    List<String> list = ListPool.get();
    list.add("first");
    list.first.are("first");
    list.release();
    list.length.are(0);
    ListPool.get().are(list);
  });
  test('Pool/Queue Test', () {
    Queue<String> queue = QueuePool.get();
    queue.addLast("first");
    queue.first.are("first");
    queue.release();
    queue.length.are(0);
    QueuePool.get().are(queue);
  });
  test('Pool/Set Test', () {
    Set<String> set = SetPool.get();
    set.add("first");
    set.first.are("first");
    set.release();
    set.length.are(0);
    SetPool.get().are(set);
  });
  test('Pool/Map Test', () {
    Map<String, String> map = MapPool.get();
    map["first"] = "second";
    map["first"].are("second");
    map.release();
    map.length.are(0);
    MapPool.get().are(map);
  });
}
