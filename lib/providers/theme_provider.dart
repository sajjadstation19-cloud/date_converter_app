import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔹 مزوّد الثيم (Theme) للتطبيق
/// يخزن اختيار المستخدم (فاتح / داكن / تلقائي) في SharedPreferences
class ThemeProvider extends ChangeNotifier {
  static const _kKey = 'theme_mode'; // values: 'system' | 'light' | 'dark'

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get themeMode => _mode;

  /// تحميل الإعداد المحفوظ من التخزين المحلي
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kKey);

    switch (v) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      default:
        _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// تحديث الثيم وحفظه
  Future<void> setThemeMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final v = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };

    await prefs.setString(_kKey, v);
  }
}
