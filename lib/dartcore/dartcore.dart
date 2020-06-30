// Copyright 2020 mathru. All rights reserved.

/// Masamune dart core library
///
/// To use, import `package:masamune/dartcore/dartcore.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune.dartcore;

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

part 'pool/list.dart';
part 'pool/map.dart';
part 'pool/sortedmap.dart';
part 'pool/object.dart';
part 'pool/queue.dart';
part 'pool/set.dart';

part 'cache/object.dart';

part 'utility/sortedmap.dart';
part 'utility/const.dart';
part 'utility/prefs.dart';
part 'utility/config.dart';
part 'utility/extensions.dart';
part 'utility/functions.dart';
part 'utility/json.dart';
part 'utility/log.dart';
part 'utility/math.dart';
part 'utility/paths.dart';
part 'utility/texts.dart';
