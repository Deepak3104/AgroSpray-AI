import 'package:agro_spray/services/local_storage_service.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required LocalStorageService localStorageService}) : _localStorageService = localStorageService;

  final LocalStorageService _localStorageService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void loadThemeMode() {
    final value = _localStorageService.getThemeMode();
    switch (value) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    await _localStorageService.saveThemeMode(themeMode.name);
  }

  Future<void> toggleDarkMode(bool value) {
    return setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}
