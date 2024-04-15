import 'package:flutter/material.dart';

const appBarTheme = AppBarTheme(titleTextStyle: TextStyle(fontSize: 17));

class AppTheme {
  static final lightTheme =
      ThemeData.light(useMaterial3: true).copyWith(appBarTheme: appBarTheme);
  static final darkTheme =
      ThemeData.dark(useMaterial3: true).copyWith(appBarTheme: appBarTheme);
}
