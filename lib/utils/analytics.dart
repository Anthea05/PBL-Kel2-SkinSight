import 'package:flutter/foundation.dart';

/// Analitik v2.0 (§14, usulan, dengan persetujuan pengguna).
/// Prototype: hanya log debug, tanpa foto/teks hasil mentah.
abstract final class AppAnalytics {
  static void log(String event, [Map<String, Object?> params = const {}]) {
    if (kDebugMode) {
      debugPrint('[analytics] $event $params');
    }
  }
}
