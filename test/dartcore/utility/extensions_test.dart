import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test('Utility/Extensions/String Test', () {
    "###AAA###".trimString("#").are("AAA");
    "###AAA###".trimStringLeft("#").are("AAA###");
    "###AAA###".trimStringRight("#").are("###AAA");
    "15".toInt().are(15);
    "5.85".toDouble().are(5.85);
    "True".toBool().are(true);
    "false".toBool().are(false);
  });
  test('Utility/Extensions/Limit Test', () {
    100.limit(10, 50).are(50);
    5.limitLow(10).are(10);
    100.limitHigh(50).are(50);
    100.0.limit(10, 50).are(50);
    5.0.limitLow(10).are(10);
    100.0.limitHigh(50).are(50);
  });
}
