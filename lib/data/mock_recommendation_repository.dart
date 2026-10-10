import 'dart:async';

import '../models/skin_recommendation.dart';

/// Prototype model AI v2.0 (Fase A: data tiruan mengikuti kontrak §8).
/// Fase B mengganti isi fetch dengan panggilan model nyata + validasi sama.
class MockRecommendationRepository {
  MockRecommendationRepository._();
  static final instance = MockRecommendationRepository._();

  static const Duration simulatedLatency = Duration(milliseconds: 900);
  static const Duration timeout = Duration(seconds: 20);
  static const int maxRetry = 3;

  Future<SkinRecommendation> fetchRecommendation({
    List<int>? quizAnswers,
    String scenario = 'normal',
    Duration? delayOverride,
  }) async {
    final delay = delayOverride ??
        (scenario == 'timeout' ? timeout + const Duration(seconds: 1) : simulatedLatency);
    final json = await Future<Map<String, Object?>>.delayed(delay, () {
      switch (scenario) {
        case 'pendek':
          return _short;
        case 'panjang':
          return _long;
        case 'rusak':
          return _broken;
        case 'timeout':
          return _normal;
        default:
          return _normal;
      }
    }).timeout(timeout, onTimeout: () {
      throw TimeoutException('Model timeout melebihi 20 detik');
    });
    return SkinRecommendation.fromJson(json);
  }

  static const Map<String, Object?> _normal = {
    'schema_version': '1.0',
    'tipe_kulit': 'Kombinasi (T-Zone)',
    'penjelasan_singkat':
        'Area dahi dan hidung cenderung berminyak, pipi relatif normal. Fokus pada pembersih lembut dan hidrasi ringan.',
    'zat_aktif_rekomendasi': [
      {'nama': 'Niacinamide', 'fungsi': 'Membantu menyeimbangkan minyak berlebih.'},
      {'nama': 'Hyaluronic Acid', 'fungsi': 'Menjaga hidrasi tanpa rasa berat.'},
      {'nama': 'Salicylic Acid', 'fungsi': 'Membantu membersihkan pori tersumbat.'},
    ],
    'zat_aktif_dihindari': ['Alkohol denat', 'Fragrance kuat'],
    'rutinitas_harian': {
      'pagi': [
        'Cuci muka dengan pembersih lembut.',
        'Pakai pelembap ringan berbahan dasar air.',
        'Aplikasikan tabir surya SPF 30+.',
      ],
      'malam': [
        'Bersihkan wajah dua tahap bila memakai tabir surya.',
        'Pakai niacinamide sesuai petunjuk.',
        'Kunci dengan pelembap ringan.',
      ],
    },
    'perawatan_tambahan': ['Eksfoliasi 1x seminggu.', 'Masker tanah liat pada T-zone.'],
    'sumber_referensi': [
      {'judul': 'Rujukan umum perawatan kulit kombinasi', 'tahun_atau_penerbit': 'Belum diverifikasi'}
    ],
  };

  static const Map<String, Object?> _short = {
    'schema_version': '1.0',
    'tipe_kulit': 'Normal',
    'penjelasan_singkat': 'Kulit relatif seimbang. Pertahankan rutinitas dasar.',
    'zat_aktif_rekomendasi': [
      {'nama': 'Glycerin', 'fungsi': 'Menjaga kelembapan.'},
    ],
    'zat_aktif_dihindari': ['Scrub kasar'],
    'rutinitas_harian': {
      'pagi': ['Cuci muka lembut.', 'Tabir surya.'],
      'malam': ['Cuci muka lembut.', 'Pelembap.'],
    },
    'perawatan_tambahan': ['Tidur cukup.'],
    'sumber_referensi': [],
  };

  static const Map<String, Object?> _long = {
    'schema_version': '1.0',
    'tipe_kulit': 'Rentan Berjerawat',
    'penjelasan_singkat':
        'Kulit menunjukkan kecenderungan breakout dengan minyak berlebih dan pori tersumbat. Diperlukan rutinitas konsisten dan lembut. Kalimat ini sengaja panjang untuk menguji batas 280 karakter pada penjelasan singkat hasil rekomendasi model agar UI memotong dengan tombol Selengkapnya.',
    'zat_aktif_rekomendasi': [
      {'nama': 'Salicylic Acid', 'fungsi': 'Membantu membersihkan pori tersumbat.'},
      {'nama': 'Niacinamide', 'fungsi': 'Membantu menyeimbangkan minyak.'},
      {'nama': 'Azelaic Acid', 'fungsi': 'Membantu merawat bekas jerawat.'},
      {'nama': 'Zinc PCA', 'fungsi': 'Membantu mengontrol kilap.'},
      {'nama': 'Centella Asiatica', 'fungsi': 'Membantu menenangkan kulit.'},
      {'nama': 'Item keenam yang harus dipotong', 'fungsi': 'Tidak tampil.'},
    ],
    'zat_aktif_dihindari': ['Minyak kelapa', 'Fragrance kuat', 'Alkohol denat', 'Scrub kasar', 'Item kelima', 'Item keenam'],
    'rutinitas_harian': {
      'pagi': ['Langkah 1.', 'Langkah 2.', 'Langkah 3.', 'Langkah 4.', 'Langkah 5.', 'Langkah 6.', 'Langkah 7.'],
      'malam': ['Langkah 1.', 'Langkah 2.', 'Langkah 3.', 'Langkah 4.', 'Langkah 5.', 'Langkah 6.', 'Langkah 7.'],
    },
    'perawatan_tambahan': ['Satu.', 'Dua.', 'Tiga.', 'Empat.', 'Lima.'],
    'sumber_referensi': [
      {'judul': 'Satu', 'tahun_atau_penerbit': '2024'},
      {'judul': 'Dua', 'tahun_atau_penerbit': '2024'},
      {'judul': 'Tiga', 'tahun_atau_penerbit': '2024'},
      {'judul': 'Empat', 'tahun_atau_penerbit': '2024'},
    ],
  };

  static const Map<String, Object?> _broken = {
    'schema_version': '1.0',
    'tipe_kulit': 'Kombinasi (T-Zone)',
    'zat_aktif_rekomendasi': 'RUSAK_BUKAN_LIST',
    'rutinitas_harian': {'pagi': 'RUSAK', 'malam': []},
  };
}
