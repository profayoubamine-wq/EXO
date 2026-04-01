import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1565C0);     // Deep Blue
  static const Color secondary = Color(0xFF00ACC1);   // Cyan
  static const Color accent = Color(0xFFFF6F00);      // Amber
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color bg = Color(0xFFF5F7FA);

  // Subject color palette
  static const List<Color> subjectColors = [
    Color(0xFF1565C0), // Blue
    Color(0xFF2E7D32), // Green
    Color(0xFFC62828), // Red
    Color(0xFF6A1B9A), // Purple
    Color(0xFFE65100), // Deep Orange
    Color(0xFF00838F), // Teal
    Color(0xFF558B2F), // Light Green
    Color(0xFF4527A0), // Deep Purple
    Color(0xFF283593), // Indigo
    Color(0xFF00695C), // Dark Teal
  ];

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}
