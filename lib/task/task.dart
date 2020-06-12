// Copyright 2020 mathru. All rights reserved.

/// Masamune task system library
///
/// To use, import `package:masamune/task/task.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune.task;

import 'dart:core';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:masamune_core/dartcore/dartcore.dart';
import 'package:masamune_core/interface/interface.dart';
import 'package:masamune_core/path/path.dart';

part 'core/timing.dart';
part 'core/extensions.dart';

part 'interface/itask.dart';

part 'component/task.dart';
part 'component/taskunit.dart';
part 'component/tasklist.dart';
part 'component/taskdocument.dart';
part 'component/taskcollection.dart';
part 'component/taskqueue.dart';
part 'component/taskmixin.dart';
