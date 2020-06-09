import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test('Utility/Math Test', () {
    Math.lerp(1, 5, 0.5).are(3);
    Math.mod(5, 2).are(1);
  });
}
