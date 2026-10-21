import 'package:flutter/material.dart';
import '../data/skin_journey_store.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_header.dart';
import '../widgets/skin_page_background.dart';
import 'skin_checkin_quiz_page.dart';
import 'skin_journey_photos_page.dart';

/// Halaman tengah pada sketsa: ringkasan hari ini, Kuis & Scan terpisah,
/// lalu satu konfirmasi manual untuk memasukkan event ke timeline.
class SkinCheckinPage extends StatelessWidget {
  const SkinCheckinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = SkinJourneyStore.instance;
    return Scaffold(
      backgroundColor: SkinTokens.background,
      body: SkinPageBackground(
          child: SafeArea(
              child: Center(
                  child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
        child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final today = DateTime.now();
              return Column(children: [
                const SkinPageHeader(
                    title: 'Check-in Hari Ini', backKey: Key('checkin-back')),
                Expanded(
                    child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
                        children: [
                      Text('${today.day}/${today.month}/${today.year}',
                          style: SkinTokens.caption),
                      const SizedBox(height: 7),
                      const Text('Bagaimana kulitmu minggu ini?',
                          style: SkinTokens.title),
                      const SizedBox(height: 8),
                      const Text(
                          'Isi kuis singkat untuk semua kondisi yang dipantau. Tambahkan foto kalau ingin, lalu konfirmasi.',
                          style: SkinTokens.caption),
                      const SizedBox(height: 22),
                      _card(children: [
                        const Text('Ringkasan kondisi',
                            style: SkinTokens.section),
                        const SizedBox(height: 7),
                        const Text(
                            'Temuan foto terakhir dan laporan hari ini dicatat terpisah.',
                            style: SkinTokens.caption),
                        const SizedBox(height: 12),
                        if (store.trackedConditions.isEmpty)
                          const Text(
                              'Belum ada kondisi yang dipilih. Kuis bisa dipakai untuk membuat catatan awal.',
                              style: SkinTokens.caption)
                        else
                          ...store.trackedConditions.map((condition) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(children: [
                                const Icon(Icons.circle,
                                    size: 8, color: SkinTokens.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(condition,
                                          style: const TextStyle(
                                              color: SkinTokens.ink,
                                              fontWeight: FontWeight.w700)),
                                      Builder(builder: (_) {
                                        final p = store.pendingPhotos.isNotEmpty
                                            ? store.pendingPhotos.last
                                            : (store.photos.isEmpty
                                                ? null
                                                : store.photos.first);
                                        final n = p?.detectionCounts[condition];
                                        final area =
                                            p?.segmentationAreas[condition];
                                        final prefix =
                                            store.pendingPhotos.isNotEmpty
                                                ? 'Sesi terbaru'
                                                : 'Foto terakhir';
                                        return Text(
                                            n != null
                                                ? '$prefix: $n temuan'
                                                : area != null
                                                    ? '$prefix: ${(area * 100).toStringAsFixed(0)}% mask'
                                                    : 'Belum ada pengamatan baru',
                                            style: SkinTokens.caption);
                                      }),
                                    ])),
                                if (store.draftReports.containsKey(condition))
                                  Text(store.draftReports[condition]!,
                                      style: SkinTokens.caption),
                              ]))),
                      ]),
                      const SizedBox(height: 16),
                      const Text('Lengkapi sesi hari ini',
                          style: SkinTokens.section),
                      const SizedBox(height: 12),
                      _actionCard(context,
                          icon: Icons.fact_check_outlined,
                          title: 'Kuis check-in',
                          description: store.checkinQuizDone
                              ? 'Jawaban siap. Ketuk jika ingin mengubah.'
                              : 'Ceritakan perubahan Acne, PIH, atau kondisi yang sedang dipantau.',
                          done: store.checkinQuizDone,
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const SkinCheckinQuizPage()))),
                      const SizedBox(height: 12),
                      _actionCard(context,
                          icon: Icons.add_a_photo_outlined,
                          title: 'Sesi scan (opsional)',
                          description: store.pendingPhotos.isEmpty
                              ? 'Tambah satu atau beberapa foto. Tidak harus scan ulang.'
                              : '${store.pendingPhotos.length} foto siap dikonfirmasi. Ketuk untuk menambah atau menghapus.',
                          done: store.pendingPhotos.isNotEmpty,
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const SkinJourneyPhotosPage()))),
                    ])),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 15),
                    child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                            onPressed: store.checkinQuizDone &&
                                    store.hasCheckinDue
                                ? () {
                                    final severe =
                                        store.draftIrritation == 'Sedang-berat';
                                    if (store.confirmCheckin()) {
                                      if (severe) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Keluhan sedang-berat perlu dinilai tenaga kesehatan. Jangan menunggu check-in berikutnya.')));
                                      }
                                      Navigator.of(context).pop();
                                    }
                                  }
                                : null,
                            icon: const Icon(Icons.check_circle_outline),
                            label:
                                const Text('Konfirmasi & simpan check-in')))),
              ]);
            }),
      )))),
    );
  }

  Widget _card({required List<Widget> children}) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SkinTokens.border)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool done,
    required VoidCallback onTap,
  }) =>
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SkinTokens.border)),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: SkinTokens.mint,
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: SkinTokens.primary)),
                const SizedBox(width: 13),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: const TextStyle(
                              color: SkinTokens.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 5),
                      Text(description, style: SkinTokens.caption),
                    ])),
                Icon(done ? Icons.check_circle : Icons.chevron_right,
                    color: SkinTokens.primary),
              ])),
        ),
      );
}
