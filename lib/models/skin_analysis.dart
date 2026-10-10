import 'dart:typed_data';

import 'skin_recommendation.dart';

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
  final int hydration;
  final Uint8List? selfieBytes;
  final SkinRecommendation? recommendation;

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
    this.hydration = 78,
    this.selfieBytes,
    this.recommendation,
  });

  SkinAnalysis copyWith({
    String? id,
    DateTime? analyzedAt,
    int? score,
    String? title,
    String? skinType,
    int? oil,
    int? pores,
    int? acne,
    int? redness,
    int? hydration,
    Uint8List? selfieBytes,
    SkinRecommendation? recommendation,
  }) {
    return SkinAnalysis(
      id: id ?? this.id,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      score: score ?? this.score,
      title: title ?? this.title,
      skinType: skinType ?? this.skinType,
      oil: oil ?? this.oil,
      pores: pores ?? this.pores,
      acne: acne ?? this.acne,
      redness: redness ?? this.redness,
      hydration: hydration ?? this.hydration,
      selfieBytes: selfieBytes ?? this.selfieBytes,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}
