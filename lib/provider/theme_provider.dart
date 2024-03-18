import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  late bool isDark;

  Future<void> setDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDark", true);
    isDark = true;
    notifyListeners();
  }

  Future<void> setLightMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDark", false);
    isDark = false;
    notifyListeners();
  }

  Future<void> setTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? darkMode = prefs.getBool("isDark");
    isDark = darkMode ?? true;
  }
}
