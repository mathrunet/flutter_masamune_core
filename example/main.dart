import 'package:masamune_core/masamune_core.dart';

void main() async {
  await Config.init();
  DataField("name", "mathru");
  String name = PathMap.get<String>("name");
  print(name);
}
