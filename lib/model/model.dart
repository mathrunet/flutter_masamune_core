// Copyright 2020 mathru. All rights reserved.

/// Masamune model system library
///
/// To use, import `package:masamune/model/model.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune.model;

import 'dart:async';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:masamune_core/dartcore/dartcore.dart';
import 'package:masamune_core/data/data.dart';
import 'package:masamune_core/interface/interface.dart';
import 'package:masamune_core/local/local.dart';
import 'package:masamune_core/path/path.dart';

part 'core/model.dart';
part 'core/modelcontext.dart';
part 'core/pathmodelmixin.dart';
part 'core/fieldmodel.dart';
part 'core/documentmodel.dart';
part 'core/collectionmodel.dart';

part 'component/localcollectionmodel.dart';
part 'component/localdocumentmodel.dart';
part 'component/searchablelocalcollectionmodel.dart';
part 'component/apidocumentmodel.dart';
part 'component/apicollectionmodel.dart';
