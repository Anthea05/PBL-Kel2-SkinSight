import 'package:flutter/material.dart';

/// Shared presentation tokens. Medical values and repository behavior live elsewhere.
abstract final class SkinTokens {
  static const primary = Color(0xFF096F65);
  static const primaryDark = Color(0xFF07594F);
  static const ink = Color(0xFF19383E);
  static const muted = Color(0xFF526B72);
  static const background = Color(0xFFF4F8F7);
  static const surface = Color(0xFFFFFFFF);
  static const mint = Color(0xFFE3F0EB);
  static const cyan = Color(0xFFD7ECF0);
  static const hero = Color(0xFFAEDAE3);
  static const border = Color(0xFFD3E1DE);
  static const coral = Color(0xFFB54150);
  static const amber = Color(0xFF96631C);
  static const blue = Color(0xFF286E8A);
  static const space = 16.0;
  static const pageInset = 20.0;
  static const radius = 16.0;
  static const controlRadius = 12.0;
  static const maxWidth = 520.0;
  static const shadows = <BoxShadow>[];

  static const title = TextStyle(
    fontSize: 26,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -.5,
  );
  static const section = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: ink,
  );
  static const body = TextStyle(fontSize: 16, height: 1.45, color: ink);
  static const caption = TextStyle(fontSize: 13, height: 1.4, color: muted);

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(seedColor: primary).copyWith(
      primary: primary,
      onPrimary: surface,
      secondary: blue,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      outline: border,
      error: coral,
      surfaceTint: Colors.transparent,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(controlRadius),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        headlineSmall: title,
        titleLarge: section,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
      ),
      dividerColor: border,
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        minimumSize: const Size(44, 52),
        shape: shape,
        elevation: 0,
        textStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 52),
        shape: shape,
        side: const BorderSide(color: border),
      )),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
      )),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2)),
      ),
    );
  }
}
