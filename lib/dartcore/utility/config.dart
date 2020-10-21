part of masamune.dartcore;

/// Class that manages the configuration of Masamune framework.
///
/// Initial values are set but can be changed at any time.
class Config {
  /// True if the config has been initialized.
  static bool get isInitialized => _isInitialized;
  static bool _isInitialized = false;
  static final String _uidKey = "DeviceUniqueIdentifier".toSHA1();
  static String _uid;
  static Directory _temporaryDirectory;
  static Directory _documentDirectory;

  /// Initialize the configuration.
  static Future init() async {
    await Prefs.init();
    if (!Prefs.containsKey(_uidKey))
      Prefs.set(_uidKey, _uid = Texts.uuid);
    else
      _uid = Prefs.getString(_uidKey);
    _temporaryDirectory = await getTemporaryDirectory();
    _documentDirectory = await getApplicationDocumentsDirectory();
    _isInitialized = true;
  }

  /// True if it is web.
  static bool get isWeb => kIsWeb;

  /// True for Android apps.
  static bool get isAndroid => !isWeb && Platform.isAndroid;

  /// True for IOS apps.
  static bool get isIOS => !isWeb && Platform.isIOS;

  /// Frame interval for updating etc.
  ///
  /// Initial value is 10ms
  static Duration frameTime = const Duration(milliseconds: 30);

  /// Interval for executing the regularly executed process.
  ///
  /// Task queue and Firebase updates etc.
  ///
  /// Initial value is 3 sec
  static Duration periodicExecutionTime = const Duration(seconds: 3);

  /// Task queue execution limit.
  ///
  /// Initial value is 10.
  static int taskQueueLimit = 10;

  /// The directory that stores temporary files.
  static Directory get temporaryDirectory => _temporaryDirectory;

  /// The directory where you want to save the document file.
  static Directory get documentDirectory => _documentDirectory;

  /// Get the UniqueID of the device.
  static String get uid {
    assert(isNotEmpty(_uid));
    if (isEmpty(_uid)) {
      Log.error("Config could not be obtained. "
          "It may not have been initialized. Try running [Config.init()]");
      return Texts.uuid;
    }
    return _uid;
  }

  /// Check the connection status.
  ///
  /// [onConnected]: Callbacks on connection.
  /// [onDisconnected]: Callbacks when you're not connected.
  static Future<ConnectivityResult> connect(
      {Function onConnected, Function onDisconnected}) async {
    ConnectivityResult result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      if (onDisconnected != null) onDisconnected();
    } else {
      if (onConnected != null) onConnected();
    }
    return result;
  }
}
