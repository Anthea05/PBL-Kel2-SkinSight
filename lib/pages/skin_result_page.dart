import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/skin_demo_data.dart';
import '../data/skin_history_repository.dart';
import '../data/skin_journey_store.dart';
import '../models/skin_analysis.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_header.dart';
import 'skin_progress_page.dart';
import 'skin_scan_page.dart';

/// Hasil satu foto. Dalam prototipe hasil berasal dari fixture demo yang
/// SAMA dengan catatan Skin Journey setelah pengguna menekan Simpan.
class SkinResultPage extends StatefulWidget {
  final Uint8List? selfieBytes;
  final SkinAnalysis? analysis;
  final bool archived;
  /// Dipakai untuk sesi foto di dalam check-in; tidak menyimpan baseline baru.
  final bool sessionPreview;
  const SkinResultPage({super.key, this.selfieBytes, this.analysis,
    this.archived = false, this.sessionPreview = false});
  @override
  State<SkinResultPage> createState() => _SkinResultPageState();
}

class _SkinResultPageState extends State<SkinResultPage> {
  late final SkinAnalysis? _data;
  bool _saving = false;
  bool _saved = false;
  static const _navy = Color(0xFF16363C);
  static const _teal = Color(0xFF087D73);
  static const _light = Color(0xFFEAF6F2);
  static const _background = Color(0xFFFFFBF4);
  static const _orange = Color(0xFFF4AD58);

  static const _education = <String, (String, String)>{
    'Acne': (
      'Bersihkan wajah dengan lembut. Benzoyl peroxide, retinoid dan azelaic acid merupakan contoh bahan yang punya dasar bukti, tetapi pilihan bergantung pada toleransi dan kondisi kulit.',
      'Efek sebagian terapi mulai dinilai setelah 6–8 minggu; evaluasi sekitar 12 minggu.'),
    'PIH': (
      'Prioritaskan perlindungan UV dan pencegahan peradangan baru. Azelaic acid termasuk bahan yang diteliti untuk hiperpigmentasi.',
      'Pemudaran noda dapat memerlukan berbulan-bulan; bukan prediksi waktu sembuh.'),
    'Dark Circle': (
      'Lingkar gelap bisa berkaitan dengan pigmen, pembuluh darah atau struktur wajah. Jangan mencoba bahan aktif dekat mata tanpa mempertimbangkan risikonya.',
      'Tidak ada estimasi durasi pemulihan yang universal.'),
    'Redness': (
      'Gunakan perawatan lembut, perhatikan pemicu iritasi dan gunakan perlindungan matahari yang sesuai.',
      'Kemerahan pada foto tidak otomatis berarti rosacea.'),
    'Wrinkle': (
      'Perlindungan UV penting. Retinoid mempunyai penelitian pendukung, tetapi perlu memperhatikan iritasi serta batas keamanannya.',
      'Sebagian penelitian menilai perubahan setelah 3–6 bulan atau lebih.'),
  };

  @override
  void initState() {
    super.initState();
    _data = widget.analysis ?? (widget.selfieBytes == null
      ? null : SkinDemoData.forPhoto(widget.selfieBytes!));
  }

  String _pct(double v) => '${(v * 100).toStringAsFixed(0)}%';
  String _date(DateTime d) => '${d.day} ${const [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'
  ][d.month - 1]} ${d.year}';

  Future<void> _save() async {
    final a = _data;
    final bytes = a?.selfieBytes ?? widget.selfieBytes;
    if (_saved || _saving || bytes == null || a == null) return;
    if (SkinJourneyStore.instance.consent != true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Izinkan pemrosesan foto di kuesioner terlebih dahulu.')));
      return;
    }
    setState(() => _saving = true);
    await SkinHistoryRepository.instance.saveLatest(
      bytes, findings: a.visualFindings, skinType: a.skinType,
      modelConnected: a.modelConnected, isDemo: a.isDemo,
      detectionCounts: a.detectionCounts,
      segmentationAreas: a.segmentationAreas,
      classConfidences: a.classConfidences,
      skinTypeConfidence: a.skinTypeConfidence,
      modelVersion: a.modelVersion,
      quality: a.isDemo ? 'pass' : 'unchecked',
    );
    if (!mounted) return;
    setState(() { _saved = true; _saving = false; });
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => const SkinProgressPage()));
  }

  @override
  Widget build(BuildContext context) {
    final a = _data;
    final photo = a?.selfieBytes ?? widget.selfieBytes;
    final hasData = a != null && (a.modelConnected || a.isDemo);
    final found = a == null || !hasData ? const <String>[] : a.visualFindings;
    final other = SkinJourneyStore.visualClasses.where((c) => !found.contains(c)).toList();
    final type = hasData ? a!.skinType : 'Belum diketahui';
    final typeDesc = switch (type) {
      'Dry' => 'Cenderung membutuhkan perhatian pada kelembapan dan toleransi bahan aktif.',
      'Oily' => 'Formulasi ringan dapat membantu kenyamanan, tanpa mengabaikan pelembap.',
      'Normal' => 'Fokuskan perawatan pada keluhan dan respons kulit.',
      'Combination' => 'Area T-zone dan pipi bisa memiliki kebutuhan yang berbeda.',
      _ => 'Estimasi jenis kulit belum tersedia.',
    };
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(padding: const EdgeInsets.fromLTRB(19, 0, 19, 24), children: [
          SkinPageHeader(title: widget.sessionPreview ? 'Hasil Sesi Foto' : 'Hasil Analisis', backKey: const Key('result-back')),
          const SizedBox(height: 9),
          ClipRRect(borderRadius: BorderRadius.circular(24), child: SizedBox(
            height: 218, child: Stack(fit: StackFit.expand, children: [
              if (photo != null) Image.memory(photo, fit: BoxFit.cover)
              else const ColoredBox(color: _light,
                child: Icon(Icons.face_retouching_natural, size: 62, color: _teal)),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xAA102D34)],
                stops: [.43, 1],
              ))),
              Positioned(left: 16, bottom: 15, right: 16,
                child: Row(children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 19),
                  const SizedBox(width: 7),
                  Expanded(child: Text(a != null ? _date(a.analyzedAt) : 'Foto terbaru',
                    style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w700, fontSize: 14))),

                ])),
            ]),
          )),
          const SizedBox(height: 23),
          const Text('Kenali kondisi kulitmu', style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w900, color: _navy,
            letterSpacing: -.7)),
          const SizedBox(height: 5),
          Text(hasData ? '${found.length} jenis temuan visual dalam sesi ini' :
            'Hasil analisis belum tersedia', style: SkinTokens.caption),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFDAF3EA), Color(0xFFEFF8F2)]),
              borderRadius: BorderRadius.circular(23)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(height: 53, width: 53,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.water_drop_outlined, color: _teal, size: 26)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ESTIMASI JENIS KULIT', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w900, color: _teal,
                  letterSpacing: 1.1)),
                const SizedBox(height: 3),
                Text(type, style: const TextStyle(fontSize: 25,
                  fontWeight: FontWeight.w900, color: _navy)),
              ])),
              if (hasData && a?.skinTypeConfidence != null)
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(_pct(a!.skinTypeConfidence!), style: const TextStyle(
                    color: _teal, fontSize: 20, fontWeight: FontWeight.w900)),
                  const Text('Confidence', style: TextStyle(
                    color: SkinTokens.muted, fontSize: 11)),
                ]),
            ]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(5, 9, 5, 8),
            child: Text(typeDesc, style: SkinTokens.caption)),
          const SizedBox(height: 17),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Temuan visual', style: SkinTokens.section),
          ]),
          const SizedBox(height: 5),
          const Text('Ringkasan temuan per kelas · jumlah deteksi, luas mask, dan confidence.',
            style: SkinTokens.caption),
          const SizedBox(height: 13),
          if (hasData) Container(
            key: const Key('result-compact-findings-v10'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xFFE8EDE7))),
            child: Column(children: [
              for (final c in found) ...[
                if (c != found.first) const Divider(height: 1,
                  color: Color(0xFFE9EEEB)),
                _findingRow(c, a!),
              ],
            ]),
          ) else Container(padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(19)),
            child: const Text('Belum ada hasil yang tersimpan.',
              style: SkinTokens.caption)),
          if (other.isNotEmpty && hasData) ...[
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.remove_circle_outline, color: SkinTokens.muted, size: 18),
              const SizedBox(width: 7),
              Expanded(child: Text('Tidak terdeteksi pada sesi ini: ${other.join(', ')}',
                style: SkinTokens.caption)),
            ]),
          ],
          const SizedBox(height: 24),
          const Text('Edukasi perawatan', style: SkinTokens.section),
          const SizedBox(height: 7),
          // Satu ringkasan, bukan deretan accordion yang menduplikasi kartu temuan.
          Container(padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE4EBE5))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in found.where(_education.containsKey)) ...[
                  if (c != found.first) const Divider(height: 22),
                  Text(c, style: const TextStyle(fontWeight: FontWeight.w800,
                    color: _teal, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(_education[c]!.$1, style: const TextStyle(
                    color: _navy, fontSize: 13, height: 1.46)),
                ],
              ])),
          if (SkinJourneyStore.instance.answers['M03'] == 'Sedang-berat' ||
              SkinJourneyStore.instance.answers['M06'] == 'Ya') ...[
            const SizedBox(height: 12),
            const Text('Jika sedang dalam perawatan dokter atau mengalami keluhan berat, utamakan arahan tenaga kesehatan.',
              style: TextStyle(color: SkinTokens.coral, fontSize: 13)),
          ],
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, color: SkinTokens.muted, size: 15),
            const SizedBox(width: 7),
            Expanded(child: Text('Hasil visual bukan diagnosis atau persentase kesembuhan.',
              style: const TextStyle(color: SkinTokens.muted, fontSize: 12, height: 1.4))),
          ]),
        ]),
      ))),
      bottomNavigationBar: widget.archived ? null : widget.sessionPreview
        ? SafeArea(minimum: const EdgeInsets.fromLTRB(18, 9, 18, 14),
            child: Center(heightFactor: 1, child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SizedBox(width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('session-preview-done'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Sesi masuk draft • Kembali'))))))
        : SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 9, 18, 14),
        child: Center(heightFactor: 1, child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const SkinScanPage())),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Ulangi'))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: FilledButton.icon(
              key: const Key('save-result'), onPressed: _saving || _saved ? null : _save,
              icon: const Icon(Icons.bookmark_add_outlined, size: 20),
              label: Text(_saving ? 'Menyimpan...' : 'Simpan ke Journey'))),
          ]),
        )),
      ),
    );
  }

  // Satu panel ringkas; setiap kelas satu BARIS, bukan kartu tinggi 156 px.
  Widget _findingRow(String name, SkinAnalysis a) {
    final detection = SkinJourneyStore.detectionClasses.contains(name);
    final amount = detection
      ? '${a.detectionCounts[name] ?? 0}'
      : '${((a.segmentationAreas[name] ?? 0) * 100).toStringAsFixed(0)}%';
    final unit = detection ? 'area' : 'mask';
    final confidence = a.classConfidences[name];
    final icon = switch (name) {
      'Acne' => Icons.grain_rounded,
      'PIH' => Icons.blur_on_rounded,
      'Dark Circle' => Icons.remove_red_eye_outlined,
      'Redness' => Icons.brightness_5_outlined,
      _ => Icons.spa_outlined,
    };
    final color = switch (name) {
      'Acne' => const Color(0xFFE67D83),
      'PIH' => const Color(0xFFE2A64B),
      'Dark Circle' => const Color(0xFF8A9ED9),
      'Redness' => const Color(0xFFCF798C),
      _ => const Color(0xFF63AFA1),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(width: 35, height: 35,
          decoration: BoxDecoration(color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 11),
        Expanded(child: Text(name, style: const TextStyle(
          color: _navy, fontWeight: FontWeight.w800, fontSize: 14))),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic, children: [
              Text(amount, style: const TextStyle(fontSize: 20,
                fontWeight: FontWeight.w900, color: _navy)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(
                fontSize: 11, color: SkinTokens.muted)),
            ]),
          if (confidence != null) Text('Keyakinan AI ${_pct(confidence)}',
            style: const TextStyle(color: SkinTokens.muted, fontSize: 10)),
        ]),
      ]),
    );
  }

}
