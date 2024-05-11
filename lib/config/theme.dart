import 'package:flutter/material.dart';

AppBarTheme appbarTheme(bool isDark) {
  return AppBarTheme(
    titleTextStyle: TextStyle(
      color: isDark ? Colors.white : Colors.black,
      fontSize: 17,
    ),
  );
}

class AppTheme {
  static final lightTheme = ThemeData.light(useMaterial3: true)
      .copyWith(appBarTheme: appbarTheme(false));
  static final darkTheme = ThemeData.dark(useMaterial3: true)
      .copyWith(appBarTheme: appbarTheme(true));
}
