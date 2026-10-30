import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales tomados del prototipo
  static const Color primaryColor = Color(0xFF6750A4); // Morado sólido prototipo
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color backgroundLavender = Color(0xFFF3EDF7); // Fondo lavanda muy claro
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1D1B20);
  static const Color textMuted = Color(0xFF49454F);

  // Colores para estados de lectura (Chips)
  static const Color statusPendingBg = Color(0xFFE6E1E5);
  static const Color statusPendingText = Color(0xFF49454F);
  
  static const Color statusReadingBg = Color(0xFFD3E4FD);
  static const Color statusReadingText = Color(0xFF1D4ED8);

  static const Color statusFinishedBg = Color(0xFFDCFCE7);
  static const Color statusFinishedText = Color(0xFF15803D);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: surfaceWhite,
      ),
      scaffoldBackgroundColor: backgroundLavender,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLavender,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF79747E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF79747E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
