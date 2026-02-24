import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the app [TextTheme] using the Inter typeface.
abstract final class AppTypography {
  static TextTheme textTheme(Color onSurface) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: onSurface),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onSurface),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: onSurface),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
      ),
    );
  }
}
