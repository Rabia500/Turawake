import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Return true if current mode is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Set a specific theme (used internally)
  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', mode.toString());
  }

  // Toggle between light and dark mode
  void toggleTheme(bool isOn) {
    final newMode = isOn ? ThemeMode.dark : ThemeMode.light;
    setTheme(newMode);
  }

  // Load stored theme
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedTheme = prefs.getString('themeMode');

    if (storedTheme == ThemeMode.dark.toString()) {
      _themeMode = ThemeMode.dark;
    } else if (storedTheme == ThemeMode.light.toString()) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }
}
