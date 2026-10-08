import 'dart:typed_data';

import '../models/skin_analysis.dart';

/// In-memory repository used as a small dummy backend for the prototype.
class SkinHistoryRepository {
  SkinHistoryRepository._();

  static final instance = SkinHistoryRepository._();

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
    ),
  ];

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

  Future<SkinAnalysis> saveLatest(Uint8List? selfieBytes) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
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
      selfieBytes: selfieBytes,
    );
    _records.insert(0, record);
    return record;
  }
}
