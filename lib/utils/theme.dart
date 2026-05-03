import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF78A083),
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFDFAF5),
      textTheme: GoogleFonts.quicksandTextTheme(),
      useMaterial3: true,
    );
  }
}
