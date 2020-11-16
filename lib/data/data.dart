// Copyright 2020 mathru. All rights reserved.

/// Masamune data library
///
/// To use, import `package:masamune/data/data.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune.data;

import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:masamune_core/dartcore/dartcore.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_core/path/path.dart';

part 'core/orderby.dart';
part 'core/geodata.dart';

part 'interface/idatafield.dart';
part 'interface/idatadocument.dart';
part 'interface/idatacollection.dart';
part 'interface/sortabledatacollectionmixin.dart';

part 'component/datafield.dart';
part 'component/datadocument.dart';
part 'component/datacollection.dart';
part 'component/runtimedocument.dart';
part 'component/runtimecollection.dart';
part 'component/temporaryfield.dart';
part 'component/temporarydocument.dart';
part 'component/temporarycollection.dart';
part 'component/multidatacollection.dart';
part 'component/searchablemultidatacollection.dart';
part 'component/datadocumentmixin.dart';
part 'component/joinabledatacollection.dart';
part 'component/joinabledatadocument.dart';
part 'component/multidatadocument.dart';
