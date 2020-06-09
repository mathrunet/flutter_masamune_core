import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test('Utility/Texts Test', () {
    String text1 = Texts.code(12, seed: 10);
    String text2 = Texts.code(12, seed: 10);
    text1.are(text2);
    text1 = Texts.id(12, seed: 10);
    text2 = Texts.id(12, seed: 10);
    text1.are(text2);
  });
}
