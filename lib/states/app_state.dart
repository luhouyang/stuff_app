import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final AdaptiveThemeMode savedThemeMode;

  bool isDarkMode = true;

  bool isNavBarCollapsed = false;
  int bottomNavIndex = 0;

  AppState({required this.savedThemeMode}) {
    if (savedThemeMode.isDark) {
      isDarkMode = true;
    } else {
      isDarkMode = false;
    }
    notifyListeners();
  }

  void setDarkMode(bool val) {
    isDarkMode = val;
    notifyListeners();
  }

  void setNavBarCollapsed(bool val) {
    isNavBarCollapsed = val;
    notifyListeners();
  }

  void setBottomNavIndex(int idx) {
    bottomNavIndex = idx;
    notifyListeners();
  }
}
