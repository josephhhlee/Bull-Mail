import 'package:flutter/material.dart';

class AppTheme {
  // Prevent instantiation
  AppTheme._();

  /// ------------------ Colors ------------------
  static const Color primary = Colors.orange;
  static const Color secondary = Colors.white;

  static final Color background = Colors.grey[200]!;
  static const Color surface = Colors.white;

  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color info = Color(0xFF0288D1);

  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black45;

  /// ------------------ Fonts ------------------
  static const String fontFamily = 'Roboto';

  /// ------------------ Text Styles ------------------
  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  static const TextStyle bodyText3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle hint = TextStyle(
    fontStyle: FontStyle.italic,
    color: Colors.grey,
    fontSize: 16,
  );

  /// ------------------ ThemeData ------------------
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      textTheme: const TextTheme(
        displayLarge: headline1,
        displayMedium: headline2,
        displaySmall: headline3,
        bodyLarge: bodyText1,
        bodyMedium: bodyText2,
        labelLarge: button,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          textStyle: button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primary),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
