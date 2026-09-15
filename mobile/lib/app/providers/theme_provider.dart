import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'lumen_theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null) {
        if (saved == 'light') {
          _themeMode = ThemeMode.light;
        } else if (saved == 'system') {
          _themeMode = ThemeMode.system;
        } else {
          _themeMode = ThemeMode.dark;
        }
        notifyListeners();
      }
    } catch (_) {
      // Default to dark mode if error
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'dark';
      if (mode == ThemeMode.light) val = 'light';
      if (mode == ThemeMode.system) val = 'system';
      await prefs.setString(_prefKey, val);
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    final nextMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }
}
