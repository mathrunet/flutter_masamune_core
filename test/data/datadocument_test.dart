import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test('Data/DataDocument/DataDocument Test', () {
    DataDocument doc = DataDocument("Root");
    doc["String"] = "string";
    doc["Int"] = 1;
    doc["Float"] = 0.5;
    doc["Bool"] = false;
    doc["String"].asString.are("string");
    doc["Int"].asInt.are(1);
    doc["Float"].asDouble.are(0.5);
    doc["Bool"].asBool.are(false);
    PathMap.get<DataField>("Root/String").data.are("string");
    PathMap.get("Root/Int").are(1);
    PathMap.get("Root/Float").are(0.5);
    PathMap.get("Root/Bool").are(false);
    TestLog.clear();
  });
  test('Data/DataDocument/DataMove Test', () {
    DataDocument doc = DataDocument("Root");
    doc["String"] = "string";
    doc["Int"] = 1;
    doc["Float"] = 0.5;
    doc["Bool"] = false;
    doc["String"].asString.are("string");
    doc["Int"].asInt.are(1);
    doc["Float"].asDouble.are(0.5);
    doc["Bool"].asBool.are(false);
    PathMap.get("Root/String").are("string");
    PathMap.get("Root/Int").are(1);
    PathMap.get("Root/Float").are(0.5);
    PathMap.get("Root/Bool").are(false);
    PathMap.get("Move/String").are(null);
    PathMap.get("Move/Int").are(null);
    PathMap.get("Move/Float").are(null);
    PathMap.get("Move/Bool").are(null);
    DataDocument move = DataDocument("Move");
    move["String"] = PathMap.get("Root/String");
    move["Int"] = PathMap.get("Root/Int");
    move["Float"] = PathMap.get("Root/Float");
    move["Bool"] = PathMap.get("Root/Bool");
    PathMap.get("Root/String").are("string");
    PathMap.get("Root/Int").are(1);
    PathMap.get("Root/Float").are(0.5);
    PathMap.get("Root/Bool").are(false);
    PathMap.get("Move/String").are("string");
    PathMap.get("Move/Int").are(1);
    PathMap.get("Move/Float").are(0.5);
    PathMap.get("Move/Bool").are(false);
    TestLog.clear();
  });
  test('Data/DataDocument/DataDispose Test', () {
    DataDocument doc = DataDocument("Root");
    doc["String"] = "string";
    doc["Int"] = 1;
    doc["Float"] = 0.5;
    doc["Bool"] = false;
    doc["String"].asString.are("string");
    doc["Int"].asInt.are(1);
    doc["Float"].asDouble.are(0.5);
    doc["Bool"].asBool.are(false);
    PathMap.get("Root/String").are("string");
    PathMap.get("Root/Int").are(1);
    PathMap.get("Root/Float").are(0.5);
    PathMap.get("Root/Bool").are(false);
    doc.remove("String");
    doc.remove("Int");
    doc["String"].asString.are(null);
    doc["Int"].asInt.are(null);
    doc["Float"].asDouble.are(0.5);
    doc["Bool"].asBool.are(false);
    PathMap.get("Root/String").are(null);
    PathMap.get("Root/Int").are(null);
    PathMap.get("Root/Float").are(0.5);
    PathMap.get("Root/Bool").are(false);
    TestLog.clear();
  });
  test('Data/DataDocument/DataListen Test', () async {
    TestLog tester = TestLog();
    PathListener.listen<DataDocument>("Root", (r) {
      tester.set(3);
      r["String"].asString.are("string");
      tester.result();
    });
    tester.set(1);
    DataDocument doc = DataDocument("Root");
    doc["String"] = "string";
    doc["Int"] = 1;
    doc["Float"] = 0.5;
    doc["Bool"] = false;
    doc["String"].asString.are("string");
    doc["Int"].asInt.are(1);
    doc["Float"].asDouble.are(0.5);
    doc["Bool"].asBool.are(false);
    tester.set(2);
    await tester.wait();
    PathMap.clear();
    PathFilter.clear();
    PathListener.clear();
  });
  test('Data/DataDocument/Filter Test', () {
    DataDocument doc = DataDocument("Root");
    PathFilter.insertGetFilter("Root/String", (v) => v + "desu");
    PathFilter.insertGetFilter("Root/String2", (v) {
      doc["String2"] = "aaa";
      return v;
    });
    PathFilter.insertSetFilter("Root/Int", (v) => 3);
    PathFilter.insertSetFilter("Root/Int2", (v) {
      doc["Int2"] = 2;
      return v;
    });
    doc["String"] = "string";
    doc["String2"] = "string";
    doc["Int"] = 1;
    doc["Int2"] = 1;
    doc["String"].asString.are("stringdesu");
    doc["String2"].asString.are("aaa");
    doc["Int"].asInt.are(3);
    doc["Int2"].asInt.are(2);
    PathMap.get("Root/String").are("stringdesu");
    PathMap.get("Root/Int").are(3);
    PathMap.get("Root/Int2").are(2);
    TestLog.clear();
  });
}
