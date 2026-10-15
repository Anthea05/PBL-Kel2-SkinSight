import 'package:flutter/material.dart';
import '../data/skin_history_repository.dart';
import '../data/skin_journey_store.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_bottom_nav.dart';
import '../widgets/skin_page_header.dart';
import 'skin_result_page.dart';
import 'skin_progress_page.dart';

class SkinHistoryPage extends StatefulWidget {
  const SkinHistoryPage({super.key});
  @override
  State<SkinHistoryPage> createState() => _SkinHistoryPageState();
}

class _SkinHistoryPageState extends State<SkinHistoryPage> {
  DateTime? _filter;
  bool _latestFirst = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SkinHistoryRepository.instance.fetchHistory().then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year} · '
    '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final history = SkinHistoryRepository.instance;
    final journey = SkinJourneyStore.instance;
    return Scaffold(backgroundColor: SkinTokens.background,
      body: SafeArea(bottom: false, child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
        child: Column(children: [
          SkinPageHeader(title: 'Riwayat Kulit', backKey: const Key('history-back'),
            trailing: IconButton(tooltip: 'Filter tanggal',
              icon: const Icon(Icons.date_range), onPressed: () async {
                final date = await showDatePicker(context: context,
                  firstDate: DateTime(2024), lastDate: DateTime(2035),
                  initialDate: _filter ?? DateTime.now());
                if (mounted) setState(() => _filter = date);
              })),
          Expanded(child: AnimatedBuilder(
            animation: Listenable.merge([history, journey]),
            builder: (context, _) {
              final scans = history.records.where((r) => _filter == null ||
                (r.analyzedAt.year == _filter!.year &&
                 r.analyzedAt.month == _filter!.month &&
                 r.analyzedAt.day == _filter!.day)).toList();
              scans.sort((a,b) => _latestFirst ? b.analyzedAt.compareTo(a.analyzedAt)
                : a.analyzedAt.compareTo(b.analyzedAt));
              final checkins = journey.checkins.where((c) => _filter == null ||
                (c.date.year == _filter!.year && c.date.month == _filter!.month &&
                  c.date.day == _filter!.day)).toList();
              return ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 24), children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                  const Text('Aktivitas yang tercatat', style: SkinTokens.section),
                  TextButton.icon(onPressed: () => setState(() => _latestFirst = !_latestFirst),
                    icon: const Icon(Icons.sort), label: Text(_latestFirst ? 'Terbaru' : 'Terlama')),
                ]),
                if (_filter != null) Align(alignment: Alignment.centerLeft,
                  child: TextButton(onPressed: () => setState(() => _filter = null),
                    child: const Text('Hapus filter tanggal'))),
                const SizedBox(height: 8),
                if (_loading) const Center(child: CircularProgressIndicator())
                else if (scans.isEmpty && checkins.isEmpty) const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('Belum ada aktivitas yang tersimpan.', style: SkinTokens.caption))
                else ...[
                  ...scans.map((s) => Card(elevation: 0, color: Colors.white,
                    child: ListTile(
                      leading: const Icon(Icons.face_retouching_natural,
                        color: SkinTokens.primary),
                      title: Text(s.title),
                      subtitle: Text('${_date(s.analyzedAt)} · '
                        'Hasil pengamatan kulit'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => SkinResultPage(analysis: s, archived: true))),
                    ))),
                  ...checkins.map((c) => Card(elevation: 0, color: Colors.white,
                    child: ListTile(
                      leading: const Icon(Icons.event_note, color: SkinTokens.primary),
                      title: const Text('Check-in Kulit'),
                      subtitle: Text('${_date(c.date)} · '
                        'Dikonfirmasi pengguna'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => const SkinProgressPage())),
                    ))),
                ],
              ]);
            },
          )),
        ]),
      ))),
      bottomNavigationBar: const SkinBottomNav(currentIndex: -1),
    );
  }
}
