part of masamune.dartcore;

/// Save and load data locally.
///
/// After initializing and initializing the data, get and save the data.
///
/// ```
/// await Prefs.init();
/// String data = Prefs.get("key");
/// Prefs.set( "test", "data" );
/// ```
class Prefs {
  /// True if the data has been initialized.
  static bool get isInitialized => _isInitialized;
  static bool _isInitialized = false;
  static SharedPreferences _preferences;

  /// Initialize the data.
  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Update data.
  static Future reload() async {
    if (_preferences == null || !isInitialized) return;
    await _preferences.reload();
  }

  /// Get the data.
  ///
  /// [key]: Key to get.
  /// [defaultValue]: Default value when there is no data.
  static dynamic get(String key, {dynamic defaultValue}) {
    if (isEmpty(key) || _preferences == null || !isInitialized)
      return defaultValue;
    if (!_preferences.containsKey(key)) return defaultValue;
    return _preferences.get(key);
  }

  /// Get the data.
  ///
  /// [key]: Key to get.
  /// [defaultValue]: Default value when there is no data.
  static String getString(String key, {String defaultValue}) {
    if (_preferences == null || !isInitialized) return defaultValue;
    if (!_preferences.containsKey(key)) return defaultValue;
    return _preferences.getString(key);
  }

  /// Get the data.
  ///
  /// [key]: Key to get.
  /// [defaultValue]: Default value when there is no data.
  static List<String> getStringList(String key, {List<String> defaultValue}) {
    if (isEmpty(key) || _preferences == null || !isInitialized)
      return defaultValue;
    if (!_preferences.containsKey(key)) return defaultValue;
    return _preferences.getStringList(key);
  }

  /// Get the data.
  ///
  /// [key]: Key to get.
  /// [defaultValue]: Default value when there is no data.
  static int getInt(String key, {int defaultValue = 0}) {
    if (isEmpty(key) || _preferences == null || !isInitialized)
      return defaultValue;
    if (!_preferences.containsKey(key)) return defaultValue;
    return _preferences.getInt(key);
  }

  /// Get the data.
  ///
  /// [key]: Key to get.
  /// [defaultValue]: Default value when there is no data.
  static double getDouble(String key, {double defaultValue = 0}) {
    if (isEmpty(key) || _preferences == null || !isInitialized)
      return defaultValue;
    if (!_preferences.containsKey(key)) return defaultValue;
    return _preferences.getDouble(key);
  }

  /// Get the data.
  ///
  /// [key]: Key to get.
  /// [defaultValue]: Default value when there is no data.
  static bool getBool(String key, {bool defaultValue = false}) {
    if (isEmpty(key) || _preferences == null || !isInitialized)
      return defaultValue;
    if (!_preferences.containsKey(key)) return defaultValue;
    return _preferences.getBool(key);
  }

  /// Get all stored keys.
  static Set<String> get keys {
    if (_preferences == null || !isInitialized) return SetPool.get();
    return _preferences.getKeys();
  }

  /// Check if data exists.
  ///
  /// True if data exists.
  ///
  /// [key]: Key to check.
  static bool containsKey(String key) {
    if (isEmpty(key) || _preferences == null || !isInitialized) return false;
    return _preferences.containsKey(key);
  }

  /// Save the data.
  ///
  /// [key]: Key to save.
  /// [value]: Value to save.
  static void set(String key, dynamic value) {
    if (isEmpty(key) || value == null || _preferences == null || !isInitialized)
      return;
    switch (value.runtimeType) {
      case (int):
        _preferences.setInt(key, value);
        break;
      case (double):
        _preferences.setDouble(key, value);
        break;
      case (String):
        _preferences.setString(key, value);
        break;
      case (bool):
        _preferences.setBool(key, value);
        break;
      case (List):
        _preferences.setStringList(key, value);
        break;
    }
  }

  /// Delete [key] from data.
  ///
  /// [key]: Key to delete.
  static void remove(String key) {
    if (isEmpty(key) || _preferences == null || !isInitialized) return;
    _preferences.remove(key);
  }

  /// Initialize the data.
  static void clear() {
    if (_preferences == null || !isInitialized) return;
    _preferences.clear();
  }
}
