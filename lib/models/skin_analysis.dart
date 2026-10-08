import 'dart:typed_data';

class SkinAnalysis {
  final String id;
  final DateTime analyzedAt;
  final int score;
  final String title;
  final String skinType;
  final int oil;
  final int pores;
  final int acne;
  final int redness;
  final Uint8List? selfieBytes;

  const SkinAnalysis({
    required this.id,
    required this.analyzedAt,
    required this.score,
    required this.title,
    required this.skinType,
    required this.oil,
    required this.pores,
    required this.acne,
    required this.redness,
    this.selfieBytes,
  });

  SkinAnalysis copyWith({Uint8List? selfieBytes}) {
    return SkinAnalysis(
      id: id,
      analyzedAt: analyzedAt,
      score: score,
      title: title,
      skinType: skinType,
      oil: oil,
      pores: pores,
      acne: acne,
      redness: redness,
      selfieBytes: selfieBytes ?? this.selfieBytes,
    );
  }
}
