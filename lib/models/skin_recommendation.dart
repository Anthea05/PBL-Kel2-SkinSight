/// Kontrak output model v2.0 (§8).
class ActiveIngredient {
  final String nama;
  final String fungsi;

  const ActiveIngredient({required this.nama, required this.fungsi});

  factory ActiveIngredient.fromJson(Map<String, Object?> json) {
    final nama = (json['nama'] as String? ?? '').trim();
    var fungsi = (json['fungsi'] as String? ?? '').trim();
    if (nama.isEmpty) throw const FormatException('zat_aktif tanpa nama');
    if (fungsi.length > 120) fungsi = '${fungsi.substring(0, 117)}…';
    return ActiveIngredient(nama: nama, fungsi: fungsi);
  }

  Map<String, Object?> toJson() => {'nama': nama, 'fungsi': fungsi};
}

class ReferenceItem {
  final String judul;
  final String tahunAtauPenerbit;

  const ReferenceItem({required this.judul, required this.tahunAtauPenerbit});

  factory ReferenceItem.fromJson(Map<String, Object?> json) {
    return ReferenceItem(
      judul: ((json['judul'] as String?) ?? '').trim(),
      tahunAtauPenerbit:
          ((json['tahun_atau_penerbit'] as String?) ?? '').trim(),
    );
  }

  Map<String, Object?> toJson() =>
      {'judul': judul, 'tahun_atau_penerbit': tahunAtauPenerbit};
}

class SkinRecommendation {
  static const allowedTypes = [
    'Normal',
    'Kombinasi (T-Zone)',
    'Cenderung Berminyak',
    'Cenderung Kering',
    'Sensitif Ringan',
    'Rentan Berjerawat',
  ];

  final String schemaVersion;
  final String tipeKulit;
  final bool tipeResolved;
  final String penjelasanSingkat;
  final List<ActiveIngredient> rekomendasi;
  final List<String> dihindari;
  final List<String> rutinPagi;
  final List<String> rutinMalam;
  final List<String> tambahan;
  final List<ReferenceItem> referensi;

  const SkinRecommendation({
    required this.schemaVersion,
    required this.tipeKulit,
    required this.tipeResolved,
    required this.penjelasanSingkat,
    required this.rekomendasi,
    required this.dihindari,
    required this.rutinPagi,
    required this.rutinMalam,
    required this.tambahan,
    required this.referensi,
  });

  static String _clip(String s, int max) {
    final t = s.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max - 1)}…';
  }

  static List<String> _clipSteps(Object? raw, {required int min, required int max, required int perStep}) {
    try {
      final list = (raw as List? ?? const [])
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .map((e) => _clip(e, perStep))
          .toList();
      if (list.length > max) return list.sublist(0, max);
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Validasi + fallback parsial (§8.4). Field rusak disembunyikan,
  /// tidak pernah melempar untuk masalah non-fatal.
  /// Melempar [FormatException] hanya bila `tipe_kulit` hilang total.
  factory SkinRecommendation.fromJson(Map<String, Object?> json) {
    final rawType = ((json['tipe_kulit'] as String?) ?? '').trim();
    if (rawType.isEmpty) {
      throw const FormatException('tipe_kulit wajib');
    }
    final resolved = allowedTypes.contains(rawType);
    final tipe = resolved ? rawType : 'Belum dapat ditentukan';

    var penjelasan =
        ((json['penjelasan_singkat'] as String?) ?? '').trim();
    if (penjelasan.length > 280) penjelasan = '${penjelasan.substring(0, 279)}…';

    var rekom = <ActiveIngredient>[];
    try {
      rekom = ((json['zat_aktif_rekomendasi'] as List? ?? const [])
              .whereType<Map>()
              .map((e) => ActiveIngredient.fromJson(
                  e.map((k, v) => MapEntry(k.toString(), v))))
              .toList());
    } catch (_) {
      rekom = [];
    }
    if (rekom.length > 5) rekom = rekom.sublist(0, 5);

    var hindari = ((json['zat_aktif_dihindari'] as List? ?? const [])
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList());
    if (hindari.length > 5) hindari = hindari.sublist(0, 5);

    final rutin = json['rutinitas_harian'];
    List<String> pagi = const [];
    List<String> malam = const [];
    if (rutin is Map) {
      pagi = _clipSteps(rutin['pagi'], min: 3, max: 6, perStep: 100);
      malam = _clipSteps(rutin['malam'], min: 3, max: 6, perStep: 100);
    }

    var tambahan = _clipSteps(json['perawatan_tambahan'],
        min: 2, max: 4, perStep: 100);

    var referensi = <ReferenceItem>[];
    try {
      referensi = ((json['sumber_referensi'] as List? ?? const [])
              .whereType<Map>()
              .map((e) => ReferenceItem.fromJson(
                  e.map((k, v) => MapEntry(k.toString(), v))))
              .where((e) => e.judul.isNotEmpty)
              .toList());
    } catch (_) {
      referensi = [];
    }
    if (referensi.length > 3) referensi = referensi.sublist(0, 3);

    return SkinRecommendation(
      schemaVersion: ((json['schema_version'] as String?) ?? '1.0').trim(),
      tipeKulit: tipe,
      tipeResolved: resolved,
      penjelasanSingkat: penjelasan,
      rekomendasi: rekom,
      dihindari: hindari,
      rutinPagi: pagi,
      rutinMalam: malam,
      tambahan: tambahan,
      referensi: referensi,
    );
  }

  Map<String, Object?> toJson() => {
        'schema_version': schemaVersion,
        'tipe_kulit': tipeKulit,
        'penjelasan_singkat': penjelasanSingkat,
        'zat_aktif_rekomendasi':
            rekomendasi.map((e) => e.toJson()).toList(),
        'zat_aktif_dihindari': dihindari,
        'rutinitas_harian': {'pagi': rutinPagi, 'malam': rutinMalam},
        'perawatan_tambahan': tambahan,
        'sumber_referensi': referensi.map((e) => e.toJson()).toList(),
      };
}
