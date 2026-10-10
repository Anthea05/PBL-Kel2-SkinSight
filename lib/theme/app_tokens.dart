import 'package:flutter/material.dart';

/// Design token SkinSight v2.0 (§10 PRD SkinSight v2.0).
/// Kanonis: primary/ink/bg/border. Varian lama dipertahankan sebagai
/// alias deprecated agar layar lama tidak rusak saat migrasi bertahap.
abstract final class AppTokens {
  // ── Kanonis v2.0 (§10.2) ──────────────────────────────
  static const Color primary = Color(0xFF087467);
  static const Color primarySoft = Color(0xFF168A78);
  static const Color ink = Color(0xFF13263A);
  static const Color inkSecondary = Color(0xFF5A6D78);
  static const Color disabled = Color(0xFF9AA9B0);
  static const Color bg = Color(0xFFF4F6F6);
  static const Color surface = Colors.white;
  static const Color surfaceWarm = Color(0xFFFFF8EB);
  static const Color border = Color(0xFFE2E9E7);
  static const Color successSoft = Color(0xFFE3F4F0);
  static const Color warnChipBg = Color(0xFFFFF0F0);
  static const Color warnChipText = Color(0xFFB3303A);
  static const Color danger = Color(0xFFE6535F);
  static const Color info = Color(0xFF35A9EE);

  // ── Alias legacy (jangan dipakai di komponen baru, migrasi §8.7) ──
  static const Color teal = primarySoft;
  static const Color deepTeal = primary;
  static const Color navy = ink;
  static const Color cream = surfaceWarm;
  static const Color pageBg = bg;
  static const Color cardBorder = border;
  static const Color muted = Color(0xFF6B7E89);
  static const Color coral = Color(0xFFFF6B70);
  static const Color orange = Color(0xFFFFB43B);
  static const Color sky = info;

  // Spacing kelipatan 8 (§10.5)
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;

  // Radius (§10.5)
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;

  // Type scale v2.0 (§10.4) — satu nilai tetap per peran
  static const double tCaption = 13;
  static const double tBody = 15;
  static const double tTitle = 16;
  static const double tH2 = 20;
  static const double tH1 = 24;
  static const double tDisplay = 28;

  static BoxDecoration card({double radius = r16}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: .06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ── Profesional: gradient + shadow tombol v2.1 ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A8A74), Color(0xFF06655A)],
  );

  static const LinearGradient primarySoftGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2BB79B), Color(0xFF168A78)],
  );

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: primary.withValues(alpha: .28),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get cardShadowSoft => [
        BoxShadow(
          color: primary.withValues(alpha: .07),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static TextStyle get display => const TextStyle(
        fontSize: tDisplay,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: ink,
      );

  static TextStyle get h1 => const TextStyle(
        fontSize: tH1,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: ink,
      );

  static TextStyle get h2 => const TextStyle(
        fontSize: tH2,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: ink,
      );

  static TextStyle get title => const TextStyle(
        fontSize: tTitle,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: ink,
      );

  static TextStyle get body => const TextStyle(
        fontSize: tBody,
        height: 1.5,
        color: ink,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: tCaption,
        height: 1.4,
        color: inkSecondary,
      );

  static TextStyle get eyebrow => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primary,
      );
}
