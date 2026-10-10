import 'package:flutter_test/flutter_test.dart';
import 'package:skinsight/data/mock_recommendation_repository.dart';
import 'package:skinsight/models/skin_recommendation.dart';

void main() {
  test('normal mock passes schema limits', () async {
    final rec = await MockRecommendationRepository.instance
        .fetchRecommendation(scenario: 'normal', delayOverride: Duration.zero);

    expect(rec.tipeResolved, isTrue);
    expect(SkinRecommendation.allowedTypes, contains(rec.tipeKulit));
    expect(rec.penjelasanSingkat.length, lessThanOrEqualTo(280));
    expect(rec.rekomendasi.length, lessThanOrEqualTo(5));
    expect(rec.dihindari.length, lessThanOrEqualTo(5));
    expect(rec.rutinPagi.length, lessThanOrEqualTo(6));
    expect(rec.tambahan.length, lessThanOrEqualTo(4));
    expect(rec.referensi.length, lessThanOrEqualTo(3));
  });

  test('long mock is clipped to limits', () async {
    final rec = await MockRecommendationRepository.instance
        .fetchRecommendation(scenario: 'panjang', delayOverride: Duration.zero);

    expect(rec.rekomendasi.length, 5);
    expect(rec.dihindari.length, 5);
    expect(rec.rutinPagi.length, 6);
    expect(rec.tambahan.length, 4);
    expect(rec.referensi.length, 3);
  });

  test('broken mock degrades without empty screen data', () async {
    final rec = await MockRecommendationRepository.instance
        .fetchRecommendation(scenario: 'rusak', delayOverride: Duration.zero);

    expect(rec.tipeKulit, 'Kombinasi (T-Zone)');
    expect(rec.rekomendasi, isEmpty);
  });

  test('unknown enum resolves to Belum dapat ditentukan', () {
    final rec = SkinRecommendation.fromJson({
      'schema_version': '1.0',
      'tipe_kulit': 'Tipe Aneh',
      'penjelasan_singkat': 'x',
      'zat_aktif_rekomendasi': [],
      'zat_aktif_dihindari': [],
      'rutinitas_harian': {
        'pagi': [],
        'malam': [],
      },
      'perawatan_tambahan': [],
      'sumber_referensi': [],
    });

    expect(rec.tipeResolved, isFalse);
    expect(rec.tipeKulit, 'Belum dapat ditentukan');
  });

  test('missing tipe_kulit throws FormatException', () {
    expect(
      () => SkinRecommendation.fromJson({'schema_version': '1.0'}),
      throwsFormatException,
    );
  });
}
