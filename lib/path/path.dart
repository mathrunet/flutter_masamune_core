// Copyright 2020 mathru. All rights reserved.

/// Masamune path system library
///
/// To use, import `package:masamune/path/path.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune.path;

import 'dart:async';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:masamune_core/dartcore/dartcore.dart';
import 'package:masamune_core/interface/interface.dart';

part 'component/pathmap.dart';
part 'component/pathfilter.dart';
part 'component/pathlistener.dart';
part 'component/pathlist.dart';
part 'component/pathtag.dart';
part 'component/unit.dart';
part 'component/document.dart';
part 'component/collection.dart';

part 'core/path.dart';
part 'core/protocol.dart';
part 'core/observer.dart';

part 'interface/iparent.dart';
part 'interface/ichild.dart';
part 'interface/ipath.dart';
part 'interface/iclonable.dart';
part 'interface/icollection.dart';
part 'interface/idocument.dart';
part 'interface/iunit.dart';
