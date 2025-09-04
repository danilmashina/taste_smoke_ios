import 'package:flutter/material.dart';

// Color constants from the original app
const Color darkBackground = Color(0xFF121212);
const Color cardBackground = Color(0xFF1E1E1E);
const Color accentPink = Color(0xFFE91E63);
const Color primaryText = Color(0xFFFFFFFF);
const Color secondaryText = Color(0xFFB0B0B0);

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBackground,
  primaryColor: accentPink,
  colorScheme: const ColorScheme.dark(
    primary: accentPink,
    secondary: accentPink,
    background: darkBackground,
    surface: cardBackground,
    onPrimary: primaryText,
    onSecondary: primaryText,
    onBackground: primaryText,
    onSurface: primaryText,
    error: Colors.redAccent,
    onError: primaryText,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBackground,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: primaryText,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: primaryText),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: cardBackground,
    selectedItemColor: accentPink,
    unselectedItemColor: secondaryText,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: cardBackground,
    hintStyle: const TextStyle(color: secondaryText),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide.none,
    ),
  ),
  cardTheme: CardThemeData(
    color: cardBackground,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: accentPink.withOpacity(0.2),
    labelStyle: const TextStyle(color: primaryText),
    secondaryLabelStyle: const TextStyle(color: primaryText),
    selectedColor: accentPink,
    disabledColor: Colors.grey,
    padding: const EdgeInsets.all(8.0),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentPink,
      foregroundColor: primaryText,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryText,
      side: const BorderSide(color: accentPink),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: accentPink,
    ),
  ),
);
