import 'package:flutter/foundation.dart';

import '../models/skin_analysis.dart';
import '../models/skin_recommendation.dart';

/// In-memory repository used as a small dummy backend for the prototype.
class SkinHistoryRepository {
  SkinHistoryRepository._();

  static final instance = SkinHistoryRepository._();

  /// Bertambah setiap ada simpan/hapus — dashboard mendengarkan ini
  /// agar angka dan grafik refresh tanpa restart.
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  final List<SkinAnalysis> _records = [
    SkinAnalysis(
      id: 'scan-2026-10-03',
      analyzedAt: DateTime(2026, 10, 3, 20, 15),
      score: 82,
      title: 'Kombinasi (T-Zone)',
      skinType: 'Kombinasi (T-Zone)',
      oil: 68,
      pores: 52,
      acne: 46,
      redness: 34,
      hydration: 78,
    ),
    SkinAnalysis(
      id: 'scan-2026-09-27',
      analyzedAt: DateTime(2026, 9, 27, 8, 30),
      score: 78,
      title: 'Kemerahan ringan',
      skinType: 'Sensitif Ringan',
      oil: 55,
      pores: 58,
      acne: 31,
      redness: 48,
      hydration: 71,
    ),
    SkinAnalysis(
      id: 'scan-2026-09-14',
      analyzedAt: DateTime(2026, 9, 14, 21),
      score: 72,
      title: 'Breakout dagu',
      skinType: 'Rentan Berjerawat',
      oil: 74,
      pores: 49,
      acne: 62,
      redness: 41,
      hydration: 65,
    ),
  ];

  Future<List<SkinAnalysis>> fetchLatest({int count = 7}) async {
    final items = await fetchHistory(newestFirst: true);
    if (items.length <= count) return items;
    return items.sublist(0, count);
  }

  Future<List<SkinAnalysis>> fetchHistory({
    DateTime? date,
    bool newestFirst = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final items = _records.where((record) {
      if (date == null) return true;
      return record.analyzedAt.year == date.year &&
          record.analyzedAt.month == date.month &&
          record.analyzedAt.day == date.day;
    }).toList();
    items.sort(
      (a, b) => newestFirst
          ? b.analyzedAt.compareTo(a.analyzedAt)
          : a.analyzedAt.compareTo(b.analyzedAt),
    );
    return List.unmodifiable(items);
  }

  Future<SkinAnalysis> saveAnalysis(SkinAnalysis analysis) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final now = DateTime.now();
    final record = analysis.copyWith(
      id: 'scan-${now.microsecondsSinceEpoch}',
      analyzedAt: now,
    );
    _records.insert(0, record);
    revision.value++;
    return record;
  }

  /// FR-24: hapus item riwayat + foto terkait (dengan konfirmasi di UI).
  Future<void> deleteAnalysis(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _records.removeWhere((r) => r.id == id);
    revision.value++;
  }

  /// Simpan hasil rekomendasi v2.0. Skor legacy diisi 0 (disembunyikan UI).
  Future<SkinAnalysis> saveRecommendation(
    SkinRecommendation recommendation, {
    Uint8List? selfieBytes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final now = DateTime.now();
    final record = SkinAnalysis(
      id: 'scan-${now.microsecondsSinceEpoch}',
      analyzedAt: now,
      score: 0,
      title: recommendation.tipeKulit,
      skinType: recommendation.tipeKulit,
      oil: 0,
      pores: 0,
      acne: 0,
      redness: 0,
      hydration: 0,
      selfieBytes: selfieBytes,
      recommendation: recommendation,
    );
    _records.insert(0, record);
    revision.value++;
    return record;
  }

  Future<SkinAnalysis> saveLatest(Uint8List? selfieBytes) async {
    final now = DateTime.now();
    final record = SkinAnalysis(
      id: 'scan-${now.microsecondsSinceEpoch}',
      analyzedAt: now,
      score: 82,
      title: 'Kombinasi (T-Zone)',
      skinType: 'Kombinasi (T-Zone)',
      oil: 68,
      pores: 52,
      acne: 46,
      redness: 34,
      hydration: 78,
      selfieBytes: selfieBytes,
    );
    return saveAnalysis(record.copyWith(selfieBytes: selfieBytes));
  }
}
