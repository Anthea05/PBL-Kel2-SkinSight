import 'package:flutter/material.dart';

import '../theme/skin_theme.dart';
import '../widgets/skin_page_background.dart';
import '../widgets/skin_page_header.dart';

class SkinPrivacyPage extends StatelessWidget {
  const SkinPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) => const _LegalPage(
        pageKey: Key('privacy-page'),
        title: 'Kebijakan Privasi',
        eyebrow: 'PRIVASI & DATA',
        introduction:
            'Kebijakan ini menjelaskan data yang dapat diproses oleh SkinSight, tujuan penggunaannya, penyimpanan, serta hak pengguna. Dokumen disusun dengan memperhatikan UU Nomor 27 Tahun 2022 tentang Pelindungan Data Pribadi dan peraturan Indonesia yang relevan.',
        sections: _privacySections,
      );
}

class SkinTermsPage extends StatelessWidget {
  const SkinTermsPage({super.key});

  @override
  Widget build(BuildContext context) => const _LegalPage(
        pageKey: Key('terms-page'),
        title: 'Syarat & Ketentuan',
        eyebrow: 'KETENTUAN PENGGUNAAN',
        introduction:
            'Ketentuan ini mengatur penggunaan SkinSight. Dengan menggunakan aplikasi, pengguna diharapkan memahami fungsi, batasan, serta tanggung jawabnya ketika memberikan foto dan informasi.',
        sections: _termsSections,
      );
}

class _LegalPage extends StatelessWidget {
  const _LegalPage({
    required this.pageKey,
    required this.title,
    required this.eyebrow,
    required this.introduction,
    required this.sections,
  });

  final Key pageKey;
  final String title;
  final String eyebrow;
  final String introduction;
  final List<_LegalSectionData> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      backgroundColor: SkinTokens.background,
      body: SkinPageBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
              child: Column(
                children: [
                  SkinPageHeader(
                    title: title,
                    backKey: const Key('legal-back'),
                  ),
                  Expanded(
                    child: ListView(
                      key: const Key('legal-scroll'),
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 36),
                      children: [
                        Text(
                          eyebrow,
                          style: const TextStyle(
                            color: SkinTokens.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(title, style: SkinTokens.title),
                        const SizedBox(height: 8),
                        const Text(
                          'Pembaruan draf: 18 Oktober 2026',
                          style: SkinTokens.caption,
                        ),
                        const SizedBox(height: 17),
                        Text(introduction, style: SkinTokens.body),
                        const SizedBox(height: 18),
                        const _DraftNotice(),
                        const SizedBox(height: 22),
                        for (var index = 0;
                            index < sections.length;
                            index++) ...[
                          _LegalSection(
                            number: index + 1,
                            data: sections[index],
                          ),
                          if (index < sections.length - 1)
                            const Divider(height: 30),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DraftNotice extends StatelessWidget {
  const _DraftNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: SkinTokens.mint,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: SkinTokens.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description_outlined, color: SkinTokens.primary, size: 21),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Status dokumen: draf. Identitas pengelola, kontak resmi, retensi data, ketentuan pengguna anak, dan arsitektur produksi harus dilengkapi serta ditinjau sebelum aplikasi dipublikasikan.',
              style: TextStyle(
                color: SkinTokens.ink,
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.number, required this.data});

  final int number;
  final _LegalSectionData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: SkinTokens.mint,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  color: SkinTokens.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(data.title, style: SkinTokens.section)),
          ],
        ),
        const SizedBox(height: 10),
        for (final paragraph in data.paragraphs) ...[
          Text(paragraph, style: SkinTokens.body),
          const SizedBox(height: 9),
        ],
        for (final bullet in data.bullets)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 8, right: 10),
                  decoration: const BoxDecoration(
                    color: SkinTokens.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(child: Text(bullet, style: SkinTokens.body)),
              ],
            ),
          ),
      ],
    );
  }
}

class _LegalSectionData {
  const _LegalSectionData(
    this.title, {
    this.paragraphs = const [],
    this.bullets = const [],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}

const _privacySections = <_LegalSectionData>[
  _LegalSectionData(
    'Pengelola aplikasi',
    paragraphs: [
      'SkinSight merupakan prototipe aplikasi analisis visual dan pemantauan kulit. Nama resmi pengelola, alamat atau domisili, serta kontak privasi belum dicantumkan dan wajib dilengkapi sebelum publikasi.',
    ],
  ),
  _LegalSectionData(
    'Data yang diproses',
    paragraphs: [
      'Sesuai fitur yang digunakan, SkinSight dapat memproses data berikut:',
    ],
    bullets: [
      'Data profil yang diberikan pengguna, seperti nama, email, dan nomor telepon.',
      'Foto kulit yang diambil dengan kamera atau dipilih untuk analisis.',
      'Jawaban kuis mengenai kebiasaan perawatan, iritasi, dan informasi lain yang dimasukkan pengguna.',
      'Hasil analisis visual, jenis kulit, dan nilai teknis yang dihasilkan sistem.',
      'Data Skin Journey, termasuk baseline, foto, check-in, dan timeline.',
      'Preferensi aplikasi, seperti pilihan font.',
    ],
  ),
  _LegalSectionData(
    'Tujuan penggunaan data',
    bullets: [
      'Menjalankan analisis visual berdasarkan foto dan informasi pengguna.',
      'Menampilkan hasil serta materi edukasi yang relevan.',
      'Menyusun riwayat dan Skin Journey sesuai tindakan pengguna.',
      'Membantu pengguna membandingkan catatannya dari waktu ke waktu.',
      'Menangani kendala teknis dan menjaga keamanan layanan.',
      'Foto tidak digunakan untuk publikasi, periklanan, atau pelatihan model tanpa dasar hukum dan pemberitahuan yang sesuai.',
    ],
  ),
  _LegalSectionData(
    'Dasar pemrosesan dan persetujuan',
    paragraphs: [
      'Pemrosesan data yang memerlukan persetujuan dilakukan setelah pengguna menerima informasi mengenai data yang dibutuhkan dan tujuannya. Persetujuan dapat ditarik sesuai ketentuan yang berlaku, tetapi penarikan dapat membuat fitur terkait tidak tersedia.',
    ],
  ),
  _LegalSectionData(
    'Penyimpanan dan keamanan',
    paragraphs: [
      'Pada prototipe saat ini, data profil, foto, hasil analisis, dan Skin Journey berada dalam memori aplikasi dan belum terhubung dengan backend penyimpanan permanen. Preferensi font disimpan secara lokal pada perangkat.',
      'Arsitektur produksi, masa retensi setiap jenis data, mekanisme penghapusan, kontrol akses, enkripsi, dan pengamanan komunikasi harus ditetapkan serta dicantumkan sebelum layanan dirilis.',
    ],
  ),
  _LegalSectionData(
    'Pihak ketiga dan transfer data',
    paragraphs: [
      'Kode prototipe saat ini belum menetapkan penerima data, layanan autentikasi, hosting, atau penyedia inferensi produksi. Jika pihak ketiga digunakan, SkinSight harus menjelaskan penerima, tujuan, dasar pemrosesan, dan transfer lintas negara yang terjadi.',
    ],
  ),
  _LegalSectionData(
    'Hak pengguna',
    bullets: [
      'Memperoleh informasi mengenai pemrosesan data pribadi.',
      'Mengakses dan memperoleh salinan data pribadi.',
      'Memperbaiki data yang tidak akurat.',
      'Menarik persetujuan pemrosesan.',
      'Meminta penghentian pemrosesan atau penghapusan data sesuai hukum.',
      'Mengajukan keberatan dan menggunakan hak lain berdasarkan peraturan yang berlaku.',
    ],
    paragraphs: [
      'Kontak dan mekanisme resmi untuk menjalankan hak tersebut wajib ditambahkan sebelum publikasi.',
    ],
  ),
  _LegalSectionData(
    'Perlindungan data anak',
    paragraphs: [
      'Batas usia penggunaan dan mekanisme persetujuan orang tua atau wali belum ditetapkan. Aplikasi tidak boleh dipublikasikan untuk pengguna anak sebelum persyaratan perlindungan khusus ditentukan dan diterapkan.',
    ],
  ),
  _LegalSectionData(
    'Perubahan kebijakan',
    paragraphs: [
      'Kebijakan dapat diperbarui ketika fitur, kegiatan pemrosesan, atau peraturan berubah. Perubahan material perlu diberitahukan sebelum berlaku dan persetujuan baru diminta apabila diwajibkan.',
    ],
  ),
  _LegalSectionData(
    'Kontak dan penyelesaian permintaan',
    paragraphs: [
      'Nama pengelola dan email privasi resmi belum tersedia dalam draf ini. Informasi tersebut harus diisi dan diuji sebagai kanal yang aktif sebelum dokumen dinyatakan berlaku.',
    ],
  ),
];

const _termsSections = <_LegalSectionData>[
  _LegalSectionData(
    'Tentang SkinSight',
    paragraphs: [
      'SkinSight adalah prototipe aplikasi analisis visual dan pemantauan kulit. Aplikasi membantu pengguna mencatat temuan visual, membaca informasi edukatif, serta menyusun pemantauan melalui Skin Journey. Identitas resmi pengelola wajib dilengkapi sebelum publikasi.',
    ],
  ),
  _LegalSectionData(
    'Tujuan dan batasan layanan',
    paragraphs: [
      'Hasil dibuat berdasarkan foto dan informasi yang diberikan pengguna. Hasil bersifat informatif, bukan diagnosis medis, dan tidak menggantikan pemeriksaan dokter atau tenaga kesehatan.',
      'Kualitas gambar, pencahayaan, sudut foto, keterbatasan model, dan informasi yang tersedia dapat memengaruhi hasil. Keluhan berat, menetap, memburuk, atau mengkhawatirkan perlu diperiksakan kepada tenaga kesehatan.',
    ],
  ),
  _LegalSectionData(
    'Penggunaan fitur analisis',
    bullets: [
      'Mengikuti petunjuk pengambilan foto sejauh memungkinkan.',
      'Memberikan jawaban kuis sesuai pengetahuan pengguna.',
      'Tidak memakai foto orang lain tanpa izin yang sah.',
      'Tidak menjadikan hasil sebagai satu-satunya dasar diagnosis atau tindakan medis.',
    ],
    paragraphs: [
      'SkinSight tidak menjamin setiap kondisi dapat dikenali atau seluruh hasil selalu akurat.',
    ],
  ),
  _LegalSectionData(
    'Penggunaan Skin Journey',
    paragraphs: [
      'Skin Journey digunakan untuk mengelompokkan baseline, foto, kuis, check-in, grafik, dan timeline. Informasi tersebut merupakan sarana pencatatan dan edukasi.',
      'Perubahan angka atau foto tidak selalu menunjukkan perubahan kondisi medis. Periode pemantauan dalam aplikasi bukan perkiraan maupun jaminan waktu penyembuhan.',
    ],
  ),
  _LegalSectionData(
    'Artikel dan informasi edukasi',
    paragraphs: [
      'Konten edukasi dapat mengacu pada publikasi ilmiah, pedoman kesehatan, dan sumber lain yang dicantumkan. Konten tidak dimaksudkan sebagai resep, instruksi terapi individual, atau pengganti konsultasi medis.',
    ],
  ),
  _LegalSectionData(
    'Privasi dan data pengguna',
    paragraphs: [
      'Pemrosesan data pribadi dijelaskan dalam Kebijakan Privasi SkinSight. Pengguna dapat menjalankan hak atas data pribadinya sesuai peraturan yang berlaku setelah kanal permintaan resmi tersedia.',
    ],
  ),
  _LegalSectionData(
    'Penggunaan yang dilarang',
    bullets: [
      'Menggunakan aplikasi untuk kegiatan yang melanggar hukum.',
      'Mengakses data pribadi pengguna lain tanpa izin.',
      'Memanipulasi atau menyalahgunakan sistem untuk merugikan pihak lain.',
      'Menyebarkan foto atau informasi pribadi orang lain tanpa dasar yang sah.',
    ],
  ),
  _LegalSectionData(
    'Ketersediaan layanan',
    paragraphs: [
      'Sebagai prototipe, SkinSight dapat mengalami gangguan, keterbatasan fitur, pemeliharaan, atau perubahan teknis. Ketentuan ini tidak menghilangkan kewajiban hukum pengelola maupun hak pengguna yang dilindungi peraturan.',
    ],
  ),
  _LegalSectionData(
    'Perubahan ketentuan',
    paragraphs: [
      'Perubahan ketentuan disampaikan secara wajar dan berlaku untuk penggunaan berikutnya. Persetujuan baru akan diminta apabila perubahan tersebut membutuhkannya menurut hukum.',
    ],
  ),
  _LegalSectionData(
    'Hukum yang berlaku dan kontak',
    paragraphs: [
      'Penggunaan SkinSight tunduk pada hukum Republik Indonesia. Nama pengelola, alamat, dan email resmi untuk pertanyaan atau keluhan belum tersedia dan wajib diisi sebelum ketentuan dinyatakan berlaku.',
    ],
  ),
];
