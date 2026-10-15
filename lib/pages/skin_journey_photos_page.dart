import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/skin_journey_store.dart';
import '../models/skin_analysis.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_header.dart';
import 'skin_result_page.dart';
import 'skin_scan_page.dart';

/// Layar kiri sketsa: tambah beberapa sesi, lihat hasil SETIAP foto,
/// dan kembali ke check-in ketika pengguna merasa cukup.
class SkinJourneyPhotosPage extends StatefulWidget {
  const SkinJourneyPhotosPage({super.key});
  @override
  State<SkinJourneyPhotosPage> createState() => _SkinJourneyPhotosPageState();
}

class _SkinJourneyPhotosPageState extends State<SkinJourneyPhotosPage> {
  final store = SkinJourneyStore.instance;
  static const _teal = Color(0xFF087D73);
  static const _navy = Color(0xFF16363C);

  SkinAnalysis _analysis(JourneyPhoto p) => SkinAnalysis(
    id: p.id, analyzedAt: p.date, selfieBytes: p.bytes,
    score: 0, oil: 0, pores: 0, acne: 0, redness: 0,
    title: 'Hasil sesi foto', skinType: p.skinType ?? 'Belum diketahui',
    skinTypeConfidence: p.skinTypeConfidence,
    visualFindings: p.visualFindings,
    modelConnected: p.modelConnected, isDemo: p.isDemo,
    detectionCounts: p.detectionCounts, segmentationAreas: p.segmentationAreas,
    classConfidences: p.confidences, modelVersion: p.modelVersion,
  );

  Future<void> _openResult(JourneyPhoto p) async {
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(
      builder: (_) => SkinResultPage(selfieBytes: p.bytes,
        analysis: _analysis(p), sessionPreview: true)));
  }

  Future<void> _addPhoto() async {
    if (store.consent != true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Izinkan pemrosesan foto pada kuesioner awal.')));
      return;
    }
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        builder: (_) => const SkinScanPage(returnPhoto: true)));
    if (!mounted || bytes == null) return;
    // Store menghitung fixture SATU KALI; preview membaca data yang sama.
    store.stagePhoto(bytes);
    final staged = store.pendingPhotos.last;
    await _openResult(staged);
  }

  String _finding(JourneyPhoto photo) {
    final pieces = <String>[];
    for (final name in photo.visualFindings) {
      final count = photo.detectionCounts[name];
      final area = photo.segmentationAreas[name];
      if (count != null) { pieces.add('$name $count'); }
      else if (area != null) {
        pieces.add('$name ${(area * 100).toStringAsFixed(0)}% mask');
      }
    }
    return pieces.isEmpty ? 'Belum ada hasil' : pieces.join(' · ');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SkinTokens.background,
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
      child: AnimatedBuilder(animation: store, builder: (context, _) =>
        Column(children: [
          const SkinPageHeader(title: 'Sesi Foto', backKey: Key('session-back')),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Foto hari ini', style: SkinTokens.title),
                    SizedBox(height: 5),
                    Text('Pilih foto untuk melihat hasil analisisnya.',
                      style: SkinTokens.caption),
                  ])),
                const SizedBox(width: 12),
                Material(color: _teal, borderRadius: BorderRadius.circular(17),
                  child: InkWell(key: const Key('add-session'),
                    onTap: _addPhoto,
                    borderRadius: BorderRadius.circular(17),
                    child: const SizedBox(width: 52, height: 52,
                      child: Icon(Icons.add_rounded, color: Colors.white, size: 30)))),
              ]),
              const SizedBox(height: 20),
              if (store.pendingPhotos.isEmpty)
                Container(padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SkinTokens.border)),
                  child: const Column(children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 34, color: _teal),
                    SizedBox(height: 9),
                    Text('Belum ada foto pada check-in ini',
                      textAlign: TextAlign.center, style: SkinTokens.section),
                    SizedBox(height: 6),
                    Text('Tekan + untuk menambah sesi, atau selesai tanpa foto.',
                      textAlign: TextAlign.center, style: SkinTokens.caption),
                  ])),
              for (int i = 0; i < store.pendingPhotos.length; i++)
                Padding(padding: const EdgeInsets.only(bottom: 12),
                  child: _sessionCard(store.pendingPhotos[i], i + 1)),
              if (store.pendingPhotos.isNotEmpty) ...[
                const SizedBox(height: 11),
                Container(padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(color: SkinTokens.mint,
                    borderRadius: BorderRadius.circular(19)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Ringkasan ${store.pendingPhotos.length} sesi',
                      style: SkinTokens.section),
                    const SizedBox(height: 9),
                    // Hasil per foto tidak digabung atau dirata-ratakan;
                    // pose yang berbeda tidak mewakili area identik.
                    for (int i = 0; i < store.pendingPhotos.length; i++)
                      Padding(padding: const EdgeInsets.only(bottom: 6),
                        child: Text('Sesi ${i + 1} · ${_finding(store.pendingPhotos[i])}',
                          style: SkinTokens.caption)),
                    const SizedBox(height: 4),
                    const Text('Hasil dicatat per foto, tanpa rata-rata lintas pose.',
                      style: TextStyle(color: SkinTokens.muted, fontSize: 11)),
                  ])),
              ],
            ])),
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(width: double.infinity,
              child: FilledButton.icon(
                key: const Key('finish-sessions'),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Selesai tambah sesi')))),
        ])),
    ))),
  );

  Widget _sessionCard(JourneyPhoto p, int index) => Container(
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: SkinTokens.border)),
    child: Row(children: [
      Expanded(child: InkWell(
        key: Key('open-session-$index'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openResult(p),
        child: Padding(padding: const EdgeInsets.all(11),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.memory(p.bytes, width: 78, height: 90, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text('Sesi $index', style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16, color: _navy))),
                  const Icon(Icons.chevron_right_rounded, color: _teal),
                ]),
                const SizedBox(height: 5),
                Text(_finding(p), maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: SkinTokens.caption),
                const SizedBox(height: 5),
                Text('${p.skinType ?? 'Belum diketahui'} · Lihat hasil',
                  style: const TextStyle(color: _teal,
                    fontWeight: FontWeight.w700, fontSize: 12)),
              ])),
          ]))),
      ),
      IconButton(tooltip: 'Hapus sesi $index',
        onPressed: () => store.clearPendingPhoto(p.id),
        icon: const Icon(Icons.delete_outline_rounded,
          color: SkinTokens.coral)),
      const SizedBox(width: 5),
    ]),
  );
}
