import 'package:flutter_test/flutter_test.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_test/masamune_test.dart';

void main() {
  test('Path/Path Test', () {
    Path path = Path(
        "https://mathru.net/iakdjf/iedksl.png?mode=alkjdf&data=lslkjdf#top");
    path.scheme.are("https");
    path.path.are("mathru.net/iakdjf/iedksl.png");
    path.file.are("iedksl.png");
    path.extension.are("png");
    path.query.are("mode=alkjdf&data=lslkjdf");
    path.anchor.are("top");
    path.url.are(
        "https://mathru.net/iakdjf/iedksl.png?mode=alkjdf&data=lslkjdf#top");
    path = Path("localize://Japanese/asldfjlalskdjlksj");
    path.scheme.are("localize");
    path.path.are("Japanese/asldfjlalskdjlksj");
    path.file.are("asldfjlalskdjlksj");
    path.extension.are("");
    path.query.are("");
    path.anchor.are("");
    path.url.are("localize://Japanese/asldfjlalskdjlksj");
    path = path.clone();
    path.scheme.are("localize");
    path.path.are("Japanese/asldfjlalskdjlksj");
    path.file.are("asldfjlalskdjlksj");
    path.extension.are("");
    path.query.are("");
    path.anchor.are("");
    path.url.are("localize://Japanese/asldfjlalskdjlksj");
    Paths.child(path.path, "iiiiii").are("Japanese/asldfjlalskdjlksj/iiiiii");
    path.path = Paths.child(path.path, "ksidjfijf");
    path.scheme.are("localize");
    path.path.are("Japanese/asldfjlalskdjlksj/ksidjfijf");
    path.file.are("asldfjlalskdjlksj");
    path.extension.are("");
    path.query.are("");
    path.anchor.are("");
    path.url.are("localize://Japanese/asldfjlalskdjlksj/ksidjfijf");
  });
}
