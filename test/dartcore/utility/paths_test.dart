import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test('Utility/Paths Test', () {
    String path = "/a/b/c/d";
    Paths.get(path, 2).are("b");
    path = "a.b.c";
    Paths.first(path, separator: ".").are("a");
    path = "a.b.c";
    Paths.last(path, separator: ".").are("c");
  });
}
