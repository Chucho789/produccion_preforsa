import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {

  ThemeMode themeMode =
      ThemeMode.light;

  bool get isDark =>
      themeMode == ThemeMode.dark;

  void toggleTheme(bool value) {

    themeMode = value
        ? ThemeMode.dark
        : ThemeMode.light;

    notifyListeners();
  }
}