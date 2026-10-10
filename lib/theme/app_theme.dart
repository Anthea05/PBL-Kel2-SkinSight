import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Theme v2.0 (§10.4–10.5). Font Plus Jakarta Sans via google_fonts.
/// CATATAN prototype: PRD meminta font dibundel sebagai asset agar tidak
/// diunduh runtime; saat ini memakai paket google_fonts (visual identik).
/// Migrasi ke font asset dapat dilakukan tanpa mengubah token di sini.
ThemeData buildSkinSightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
  final scheme = ColorScheme.fromSeed(
    seedColor: AppTokens.primary,
    primary: AppTokens.primary,
    secondary: AppTokens.primarySoft,
    surface: AppTokens.surface,
    error: AppTokens.danger,
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppTokens.bg,
    colorScheme: scheme,
    textTheme: text.copyWith(
      displayLarge: AppTokens.display,
      headlineMedium: AppTokens.h1,
      titleLarge: AppTokens.h2,
      titleMedium: AppTokens.title,
      bodyMedium: AppTokens.body,
      bodySmall: AppTokens.caption,
      labelLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppTokens.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(160, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTokens.primary,
        minimumSize: const Size(160, 48),
        side: const BorderSide(color: AppTokens.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppTokens.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.r12),
        borderSide: const BorderSide(color: AppTokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.r12),
        borderSide: const BorderSide(color: AppTokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.r12),
        borderSide: const BorderSide(color: AppTokens.primarySoft, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.r12),
        borderSide: const BorderSide(color: AppTokens.danger),
      ),
      labelStyle: const TextStyle(color: AppTokens.inkSecondary),
      hintStyle: const TextStyle(color: AppTokens.disabled),
    ),
    cardTheme: CardThemeData(
      color: AppTokens.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.r16),
        side: const BorderSide(color: AppTokens.border),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppTokens.successSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.r12),
      ),
    ),
  );
}
