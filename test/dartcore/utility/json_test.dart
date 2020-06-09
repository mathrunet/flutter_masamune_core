import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test('Utility/Json Test', () {
    Map<String, dynamic> test = {"AA": "BB", "CC": "DD", "EE": "FF"};
    List<dynamic> list = ["AAA", "BBB"];
    String tmp = Json.encode(test);
    Map tmp2 = Json.decode(tmp) as Map;
    Map tmp3 = Json.decodeAsMap(tmp);
    String ltmp = Json.encode(list);
    List<dynamic> tmp4 = Json.decode(ltmp) as List<dynamic>;
    List<dynamic> tmp5 = Json.decodeAsList(ltmp);
    test.are(tmp2);
    test.are(tmp3);
    list.are(tmp4);
    list.are(tmp5);
  });
}
