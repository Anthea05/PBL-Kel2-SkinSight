import 'package:flutter_test/flutter_test.dart';
import 'package:skinsight/data/quiz_scoring.dart';

void main() {
  test('oily answers raise oil and lower score vs balanced', () {
    final oily = scoreQuiz([1, 0, 3, 0, 3]);
    final balanced = scoreQuiz([3, 0, 0, 1, 0]);

    expect(oily.oil, greaterThan(balanced.oil));
    expect(oily.score, lessThan(balanced.score));
    expect(oily.skinType, isNotEmpty);
  });

  test('sensitive answers resolve to Sensitif Ringan', () {
    final result = scoreQuiz([3, 3, 0, 1, 0]);

    expect(result.skinType, 'Sensitif Ringan');
    expect(result.title, 'Kemerahan ringan');
    expect(result.redness, greaterThanOrEqualTo(55));
  });

  test('acne priority resolves to Rentan Berjerawat', () {
    final result = scoreQuiz([0, 0, 1, 0, 0]);

    expect(result.skinType, 'Rentan Berjerawat');
    expect(result.acne, greaterThanOrEqualTo(60));
  });

  test('invalid answers throw ArgumentError', () {
    expect(() => scoreQuiz([0, 0, 0]), throwsArgumentError);
    expect(() => scoreQuiz([0, 0, 0, 0, 4]), throwsArgumentError);
  });
}
