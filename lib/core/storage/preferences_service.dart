import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  late final SharedPreferences _prefs;

  static final PreferencesService instance = PreferencesService._internal();
  PreferencesService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic write methods
  Future<void> setString(String key, String value) async => await _prefs.setString(key, value);
  Future<void> setBool(String key, bool value) async => await _prefs.setBool(key, value);
  Future<void> setInt(String key, int value) async => await _prefs.setInt(key, value);

  // Generic read methods
  String getString(String key, {String defaultValue = ''}) => _prefs.getString(key) ?? defaultValue;
  bool getBool(String key, {bool defaultValue = false}) => _prefs.getBool(key) ?? defaultValue;
  int getInt(String key, {int defaultValue = 0}) => _prefs.getInt(key) ?? defaultValue;

  // Custom getters/setters for settings configuration details
  String getThemeMode() => getString('app_theme_mode', defaultValue: 'light');
  Future<void> setThemeMode(String theme) => setString('app_theme_mode', theme);

  String getLanguage() => getString('app_language', defaultValue: 'en');
  Future<void> setLanguage(String lang) => setString('app_language', lang);

  String getCurrency() => getString('app_currency', defaultValue: 'USD');
  Future<void> setCurrency(String curr) => setString('app_currency', curr);

  bool getNotificationsEnabled() => getBool('app_notifications_enabled', defaultValue: true);
  Future<void> setNotificationsEnabled(bool val) => setBool('app_notifications_enabled', val);

  bool getFirstLaunch() => getBool('app_is_first_launch', defaultValue: true);
  Future<void> setFirstLaunch(bool val) => setBool('app_is_first_launch', val);

  bool getTutorialCompleted() => getBool('app_tutorial_completed', defaultValue: false);
  Future<void> setTutorialCompleted(bool val) => setBool('app_tutorial_completed', val);

  int getLastSyncTime() => getInt('app_last_sync_timestamp', defaultValue: 0);
  Future<void> setLastSyncTime(int timestamp) => setInt('app_last_sync_timestamp', timestamp);
}
