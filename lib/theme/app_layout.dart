/// Layout & responsivitas v2.0 (§11).
abstract final class AppLayout {
  static const double maxWidth = 520;
  static const double compactBreakpoint = 360;
  static const double wideBreakpoint = 600;

  static const double marginStandard = 16;
  static const double marginCompact = 12;
  static const double sectionGap = 24;
  static const double cardGap = 12;
  static const double cardPadding = 16;

  /// Target sentuh minimum v2.0: 48x48.
  static const double minTouch = 48;

  static const double tabletMaxWidth = 720;
  static const double quizTabletMaxWidth = 640;

  static double marginFor(double width) =>
      width < compactBreakpoint ? marginCompact : marginStandard;

  static bool isCompact(double width) => width < compactBreakpoint;

  static bool isTablet(double width) => width >= wideBreakpoint;

  static double contentMax(double width) =>
      isTablet(width) ? tabletMaxWidth : maxWidth;

  static double quizContentMax(double width) =>
      isTablet(width) ? quizTabletMaxWidth : maxWidth;

  /// Skala font proporsional agar tidak overflow di HP kecil
  /// dan tidak kekecilan di tablet.
  static double scaleFor(double width) {
    if (width < 330) return 0.88;
    if (width < compactBreakpoint) return 0.94;
    if (isTablet(width)) return 1.12;
    return 1.0;
  }
}
