import 'package:flutter/material.dart';

import '../data/skin_history_repository.dart';
import '../models/skin_analysis.dart';
import 'skin_quiz_page.dart';
import 'skin_result_page.dart';

class SkinHistoryPage extends StatefulWidget {
  const SkinHistoryPage({super.key});

  @override
  State<SkinHistoryPage> createState() => _SkinHistoryPageState();
}

class _SkinHistoryPageState extends State<SkinHistoryPage> {
  static const _teal = Color(0xFF168A78);
  static const _deepTeal = Color(0xFF087467);
  static const _navy = Color(0xFF13263A);
  static const _cream = Color(0xFFFFFAF1);

  bool _newestFirst = true;
  DateTime? _selectedDate;
  late Future<List<SkinAnalysis>> _history;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _history = SkinHistoryRepository.instance.fetchHistory(
      date: _selectedDate,
      newestFirst: _newestFirst,
    );
  }

  void _toggleSort() {
    setState(() {
      _newestFirst = !_newestFirst;
      _reload();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2026, 10, 3),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      helpText: 'Pilih tanggal scan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
      _reload();
    });
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _reload();
    });
  }

  void _reloadPublic() {
    setState(() => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 350;
                return DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE1F7F5), _cream, Color(0xFFF2FAF5)],
                      stops: [0, .20, 1],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: _HistoryBackground()),
                        ),
                      ),
                      Column(
                        children: [
                          _HistoryHeader(
                            compact: compact,
                            onFilter: _pickDate,
                          ),
                          Expanded(
                            child: FutureBuilder<List<SkinAnalysis>>(
                              future: _history,
                              builder: (context, snapshot) {
                                return ListView(
                                  key: const Key('history-scroll'),
                                  physics: const ClampingScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    compact ? 14 : 20,
                                    12,
                                    compact ? 14 : 20,
                                    24,
                                  ),
                                  children: [
                                    _ListControls(
                                      newestFirst: _newestFirst,
                                      selectedDate: _selectedDate,
                                      onToggleSort: _toggleSort,
                                      onClearDate: _clearDate,
                                    ),
                                    const SizedBox(height: 12),
                                    _HistorySurface(
                                      compact: compact,
                                      loading: snapshot.connectionState ==
                                          ConnectionState.waiting,
                                      items: snapshot.data ?? const [],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          _HistoryBottomNav(compact: compact),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  final bool compact;
  final VoidCallback onFilter;

  const _HistoryHeader({required this.compact, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 12 : 18, 15, compact ? 10 : 16, 7),
      child: Row(
        children: [
          Material(
            color: Colors.white.withValues(alpha: .88),
            shape: const CircleBorder(),
            child: InkWell(
              key: const Key('history-back'),
              onTap: () => Navigator.of(context).pop(),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: compact ? 44 : 50,
                height: compact ? 44 : 50,
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: _SkinHistoryPageState._deepTeal,
                  size: 32,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Riwayat Analisis',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _SkinHistoryPageState._navy,
                fontSize: compact ? 21 : 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          TextButton(
            key: const Key('history-filter-date'),
            onPressed: onFilter,
            style: TextButton.styleFrom(
              foregroundColor: _SkinHistoryPageState._deepTeal,
              minimumSize: Size(compact ? 52 : 60, 44),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Text(
              'Filter',
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListControls extends StatelessWidget {
  final bool newestFirst;
  final DateTime? selectedDate;
  final VoidCallback onToggleSort;
  final VoidCallback onClearDate;

  const _ListControls({
    required this.newestFirst,
    required this.selectedDate,
    required this.onToggleSort,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'DAFTAR SCAN',
            style: TextStyle(
              color: Color(0xFF526E78),
              fontSize: 13,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (selectedDate != null)
          ActionChip(
            key: const Key('clear-history-filter'),
            onPressed: onClearDate,
            avatar: const Icon(Icons.close_rounded, size: 16),
            label: Text(_dateOnly(selectedDate!)),
            backgroundColor: const Color(0xFFE1F5EF),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          ),
        const SizedBox(width: 4),
        TextButton.icon(
          key: const Key('history-sort-toggle'),
          onPressed: onToggleSort,
          style: TextButton.styleFrom(
            foregroundColor: _SkinHistoryPageState._deepTeal,
            padding: const EdgeInsets.symmetric(horizontal: 5),
          ),
          label: Text(
            newestFirst ? 'Terbaru' : 'Terlama',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          icon: Icon(
            newestFirst
                ? Icons.keyboard_arrow_down_rounded
                : Icons.keyboard_arrow_up_rounded,
          ),
          iconAlignment: IconAlignment.end,
        ),
      ],
    );
  }
}

class _HistorySurface extends StatelessWidget {
  final bool compact;
  final bool loading;
  final List<SkinAnalysis> items;

  const _HistorySurface({
    required this.compact,
    required this.loading,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(compact ? 22 : 26),
        border: Border.all(color: const Color(0xFFDCEDEA)),
        boxShadow: [
          BoxShadow(
            color: _SkinHistoryPageState._navy.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: loading
          ? const SizedBox(
              height: 190,
              child: Center(
                child: CircularProgressIndicator(
                  color: _SkinHistoryPageState._teal,
                ),
              ),
            )
          : items.isEmpty
              ? const _EmptyHistory()
              : Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      _HistoryRow(item: items[index], compact: compact),
                      if (index != items.length - 1)
                        const Divider(
                          height: 1,
                          indent: 22,
                          endIndent: 22,
                          color: Color(0xFFE7ECEC),
                        ),
                    ],
                  ],
                ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final SkinAnalysis item;
  final bool compact;

  const _HistoryRow({required this.item, required this.compact});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('history-detail-${item.id}'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SkinResultPage(analysis: item, archived: true),
        ),
      ),
          child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 15 : 18,
        ),
        child: Row(
          children: [
            if (item.score > 0)
              Container(
                width: compact ? 60 : 68,
                height: compact ? 68 : 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F6F0),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Text(
                  '${item.score}',
                  style: TextStyle(
                    color: _SkinHistoryPageState._deepTeal,
                    fontSize: compact ? 27 : 31,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            if (item.score > 0) SizedBox(width: compact ? 11 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dateTime(item.analyzedAt),
                    style: TextStyle(
                      color: const Color(0xFF6A7F8B),
                      fontSize: compact ? 12 : 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _SkinHistoryPageState._navy,
                      fontSize: compact ? 15 : 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.recommendation != null
                        ? 'Rekomendasi tersimpan'
                        : 'Minyak ${item.oil}% · Kemerahan ${item.redness}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF6A7F8B),
                      fontSize: compact ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('history-delete-${item.id}'),
              tooltip: 'Hapus',
              onPressed: () =>
                  _confirmDelete(context, item.id, item.title),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFF6A7F8B),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _SkinHistoryPageState._deepTeal,
            ),
          ],
        ),
      ),
    );
  }
}

/// FR-24: konfirmasi lalu data benar-benar terhapus.
Future<void> _confirmDelete(
    BuildContext context, String id, String title) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus riwayat?'),
      content: Text('“$title” beserta fotonya akan dihapus permanen.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE6535F)),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  await SkinHistoryRepository.instance.deleteAnalysis(id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Riwayat dihapus.')),
  );
  // Muat ulang daftar.
  context.findAncestorStateOfType<_SkinHistoryPageState>()?._reloadPublic();
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            color: _SkinHistoryPageState._teal,
            size: 42,
          ),
          const SizedBox(height: 10),
          const Text(
            'Belum ada scan pada tanggal ini',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _SkinHistoryPageState._navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hapus filter tanggal untuk melihat seluruh riwayat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF71838B)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('history-empty-scan'),
            style: FilledButton.styleFrom(
              backgroundColor: _SkinHistoryPageState._deepTeal,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SkinQuizPage(),
              ),
            ),
            child: const Text('Mulai scan'),
          ),
        ],
      ),
    );
  }
}

class _HistoryBottomNav extends StatelessWidget {
  final bool compact;

  const _HistoryBottomNav({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 20,
        4,
        compact ? 14 : 20,
        compact ? 8 : 12,
      ),
      child: Container(
        height: compact ? 66 : 72,
        padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .96),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _SkinHistoryPageState._deepTeal.withValues(alpha: .10),
              blurRadius: 22,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HistoryNavItem(
                  icon: Icons.home_outlined,
                  label: 'Beranda',
                  onTap: () => Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  ),
                ),
                _HistoryNavItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Bantuan',
                  onTap: () => Navigator.of(context).pushNamed('/help'),
                ),
              ],
            ),
            Positioned(
              top: compact ? -16 : -20,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 4,
                child: InkWell(
                  key: const Key('history-open-quiz'),
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SkinQuizPage(),
                    ),
                  ),
                  child: Container(
                    width: compact ? 64 : 72,
                    height: compact ? 64 : 72,
                    decoration: const BoxDecoration(
                      color: _SkinHistoryPageState._teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.center_focus_strong_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HistoryNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6F8085), size: 25),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6F8085),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryBackground extends CustomPainter {
  const _HistoryBackground();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: .55);
    canvas.drawCircle(Offset(size.width * .83, 70), 22, paint);
    canvas.drawCircle(
      Offset(size.width * .12, size.height * .78),
      15,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _dateOnly(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')} ${_months[value.month - 1]}';

String _dateTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${_dateOnly(value)} · $hour:$minute';
}
