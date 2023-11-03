import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
  ),
  colorScheme: ColorScheme(
    background: Colors.black,
    onBackground: Colors.black,
    brightness: Brightness.dark,
    primary: Colors.grey[900]!,
    onPrimary: Colors.grey[900]!,
    secondary: Colors.grey[800]!,
    onSecondary: Colors.grey[800]!,
    error: Colors.grey[500]!,
    onError: Colors.grey[500]!,
    surface: Colors.grey[400]!,
    onSurface: Colors.grey[400]!,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.white),
  ),
);
