import 'package:flutter/material.dart';

/// Hand-crafted light and dark [ColorScheme]s.
abstract final class AppColors {
  // ── Shared palette ───────────────────────────────────────────────────
  static const Color _ecoGreen = Color(0xFF2D8F4E);
  static const Color _ecoGreenBright = Color(0xFF4ADE80);
  static const Color _errorRed = Color(0xFFDC3545);
  static const Color _errorRedSoft = Color(0xFFFF6B6B);

  // ── Light scheme ─────────────────────────────────────────────────────
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1A1A1A),
    onPrimary: Color(0xFFFAFAFA),
    secondary: Color(0xFF6B6B6B),
    onSecondary: Color(0xFFFAFAFA),
    tertiary: _ecoGreen,
    onTertiary: Colors.white,
    error: _errorRed,
    onError: Colors.white,
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF1A1A1A),
    surfaceContainerLow: Color(0xFFF2F2F2),
    outline: Color(0xFFE0E0E0),
  );

  // ── Dark scheme ──────────────────────────────────────────────────────
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF0F0F0),
    onPrimary: Color(0xFF121212),
    secondary: Color(0xFF9E9E9E),
    onSecondary: Color(0xFF121212),
    tertiary: _ecoGreenBright,
    onTertiary: Color(0xFF121212),
    error: _errorRedSoft,
    onError: Color(0xFF121212),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFF0F0F0),
    surfaceContainerLow: Color(0xFF1E1E1E),
    outline: Color(0xFF2C2C2C),
  );
}
