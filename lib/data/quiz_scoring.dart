import '../models/skin_analysis.dart';

/// Pure, deterministic scoring for the 5-question skin quiz.
///
/// Index mapping (must stay in sync with [SkinQuizPage]):
/// - Q0 morning feel: 0 T-Zone oily, 1 all-over oily, 2 dry/tight, 3 balanced
/// - Q1 sensitivity: 0 rarely, 1 sometimes, 2 often, 3 very often
/// - Q2 pores: 0 barely visible, 1 nose only, 2 T-Zone, 3 many areas
/// - Q3 priority: 0 acne/comedo, 1 dull/uneven, 2 dry/dehydrated, 3 fine lines
/// - Q4 sun exposure: 0 <30m, 1 30m-1h, 2 1-3h, 3 >3h
SkinAnalysis scoreQuiz(List<int> answers, {DateTime? now}) {
  if (answers.length != 5) {
    throw ArgumentError.value(
      answers,
      'answers',
      'Expected exactly 5 answers, got ${answers.length}.',
    );
  }
  for (var i = 0; i < answers.length; i++) {
    if (answers[i] < 0 || answers[i] > 3) {
      throw ArgumentError.value(
        answers,
        'answers',
        'Answer at index $i out of range 0..3.',
      );
    }
  }

  final morning = answers[0];
  final sensitivity = answers[1];
  final poreAnswer = answers[2];
  final priority = answers[3];
  final sun = answers[4];

  const oilByMorning = [65, 85, 25, 45];
  const rednessBySensitivity = [20, 35, 55, 70];
  const poresByAnswer = [25, 45, 60, 75];
  const hydrationByMorning = [70, 60, 45, 82];

  var oil = oilByMorning[morning];
  var redness = rednessBySensitivity[sensitivity];
  var pores = poresByAnswer[poreAnswer];
  var hydration = hydrationByMorning[morning];

  // Priority concern nudges the related metric.
  switch (priority) {
    case 0:
      oil += 5;
    case 2:
      hydration -= 8;
    case 1:
      redness += 4;
  }
  final acne = switch (priority) {
    0 => 62,
    1 => 35,
    2 => 25,
    _ => 30,
  };

  // Sun exposure dries and reddens slightly.
  redness += sun * 2;
  hydration -= sun * 2;

  oil = oil.clamp(5, 95);
  pores = pores.clamp(5, 95);
  final acneClamped = acne.clamp(5, 95);
  redness = redness.clamp(5, 95);
  hydration = hydration.clamp(30, 95);

  final penalty =
      (oil > 60 ? (oil - 60) * 0.4 : 0) +
      (pores > 40 ? (pores - 40) * 0.3 : 0) +
      acneClamped * 0.15 +
      redness * 0.12 +
      ((80 - hydration).clamp(0, 40)) * 0.2 +
      sun * 1.0;
  final score = (95 - penalty).round().clamp(45, 96);

  final skinType = _resolveSkinType(
    morning: morning,
    acne: acneClamped,
    redness: redness,
  );
  final title = _resolveTitle(
    skinType: skinType,
    acne: acneClamped,
    redness: redness,
  );

  return SkinAnalysis(
    id: 'quiz-draft',
    analyzedAt: now ?? DateTime.now(),
    score: score,
    title: title,
    skinType: skinType,
    oil: oil,
    pores: pores,
    acne: acneClamped,
    redness: redness,
    hydration: hydration,
  );
}

String _resolveSkinType({
  required int morning,
  required int acne,
  required int redness,
}) {
  if (acne >= 60) return 'Rentan Berjerawat';
  if (redness >= 55) return 'Sensitif Ringan';
  return switch (morning) {
    0 => 'Kombinasi (T-Zone)',
    1 => 'Cenderung Berminyak',
    2 => 'Cenderung Kering',
    _ => 'Normal',
  };
}

String _resolveTitle({
  required String skinType,
  required int acne,
  required int redness,
}) {
  if (acne >= 60) return 'Breakout aktif';
  if (redness >= 55) return 'Kemerahan ringan';
  return skinType;
}
