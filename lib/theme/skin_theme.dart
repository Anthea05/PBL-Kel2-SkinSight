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

  static ThemeData theme({String fontFamily = 'Roboto'}) {
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
    const textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        height: 1.08,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: -1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 34,
        height: 1.1,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: -1,
      ),
      displaySmall: TextStyle(
        fontSize: 30,
        height: 1.14,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: -.8,
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        height: 1.16,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: -.65,
      ),
      headlineMedium: title,
      headlineSmall: TextStyle(
        fontSize: 23,
        height: 1.22,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: -.35,
      ),
      titleLarge: section,
      titleMedium: TextStyle(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: ink,
        letterSpacing: -.1,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: body,
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: ink),
      bodySmall: caption,
      labelLarge: TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: ink,
        letterSpacing: .1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: muted,
        letterSpacing: .15,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: muted,
        letterSpacing: .2,
      ),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: const IconThemeData(color: primaryDark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -.25,
        ),
        iconTheme: IconThemeData(color: primaryDark),
      ),
      listTileTheme: ListTileThemeData(
        textColor: ink,
        iconColor: primaryDark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          height: 1.4,
          color: muted,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -.25,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          height: 1.45,
          color: muted,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: mint,
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: primaryDark)),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ink,
        )),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: surface,
        ),
        actionTextColor: const Color(0xFFA9E5D7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: mint,
        selectedColor: primary,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: surface,
        ),
      ),
      dividerColor: border,
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        minimumSize: const Size(44, 52),
        shape: shape,
        elevation: 0,
        textStyle: TextStyle(
            fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700),
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
