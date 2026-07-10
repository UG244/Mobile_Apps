import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const _themeModeKey = 'app_theme_mode';
  static const _notificationsKey = 'app_notifications_enabled';

  ThemeMode _themeMode = ThemeMode.light;
  bool _notificationsEnabled = true;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.light.index;
    _themeMode = ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1).toInt()];
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    notifyListeners();
  }
}
