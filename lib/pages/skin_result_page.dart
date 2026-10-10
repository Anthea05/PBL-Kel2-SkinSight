import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/skin_history_repository.dart';
import '../models/skin_analysis.dart';
import '../models/skin_recommendation.dart';
import '../theme/app_copy.dart';
import '../theme/app_layout.dart';
import '../theme/app_tokens.dart';
import '../utils/analytics.dart';
import 'skin_scan_page.dart';

/// Layar Result v2.0 (§7.5, §9.3): rekomendasi perawatan terstruktur.
/// Signature: timeline rutinitas pagi/malam (bukan cincin skor).
/// BottomNav disembunyikan di layar ini. Back → Beranda (konfirmasi bila
/// belum disimpan). Mode baca (`archived`) menyembunyikan tombol Simpan.
class SkinResultPage extends StatefulWidget {
  final Uint8List? selfieBytes;
  final SkinAnalysis? analysis;
  final SkinRecommendation? recommendation;
  final bool archived;
  final bool lowAccuracy;

  const SkinResultPage({
    super.key,
    this.selfieBytes,
    this.analysis,
    this.recommendation,
    this.archived = false,
    this.lowAccuracy = false,
  });

  @override
  State<SkinResultPage> createState() => _SkinResultPageState();
}

class _SkinResultPageState extends State<SkinResultPage> {
  bool _isPagi = true;
  bool _expandPenjelasan = false;
  bool _expandZat = false;
  bool _saved = false;
  bool _saving = false;

  SkinRecommendation? get _rec {
    if (widget.recommendation != null) return widget.recommendation;
    final legacy = widget.analysis?.recommendation;
    if (legacy != null) return legacy;
    final a = widget.analysis;
    if (a == null) return null;
    // Kompatibilitas data lama (skor): tampilkan tipe + ajakan scan ulang.
    return SkinRecommendation(
      schemaVersion: '1.0-legacy',
      tipeKulit: a.skinType,
      tipeResolved: true,
      penjelasanSingkat:
          'Data lama dari versi skor. Lakukan scan ulang untuk rutinitas pagi/malam dan zat aktif.',
      rekomendasi: const [],
      dihindari: const [],
      rutinPagi: const [],
      rutinMalam: const [],
      tambahan: const [],
      referensi: const [],
    );
  }

  Future<void> _onBack() async {
    if (!widget.archived && !_saved && _rec != null) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Buang hasil?'),
          content: const Text(
              'Hasil belum disimpan. Kembali ke Beranda akan membuang hasil ini.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Tetap'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Buang'),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (_saving) return;
    final rec = _rec;
    if (rec == null) return;
    setState(() => _saving = true);
    try {
      await SkinHistoryRepository.instance.saveRecommendation(
        rec,
        selfieBytes: widget.selfieBytes ?? widget.analysis?.selfieBytes,
      );
      AppAnalytics.log('result_saved', {});
      if (!mounted) return;
      setState(() {
        _saved = true;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hasil berhasil disimpan ke riwayat.')),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rec = _rec;
    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppLayout.maxWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxWidth < AppLayout.compactBreakpoint;
                final margin = AppLayout.marginFor(constraints.maxWidth);
                return Column(
                  children: [
                    _Header(compact: compact, onBack: _onBack),
                    Expanded(
                      child: rec == null
                          ? _EmptyBody(onRetake: _onBack)
                          : ListView(
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                  margin, 4, margin, 16),
                              children: [
                                if (widget.lowAccuracy)
                                  const _AccuracyNotice(),
                                if (widget.archived)
                                  const _ArchivedNotice(),
                                _TipeCard(
                                  rec: rec,
                                  expanded: _expandPenjelasan,
                                  onToggle: () => setState(() =>
                                      _expandPenjelasan = !_expandPenjelasan),
                                ),
                                const SizedBox(height: AppLayout.cardGap),
                                if (!rec.tipeResolved)
                                  const _UnresolvedNotice(),
                                _RoutineCard(
                                  rec: rec,
                                  isPagi: _isPagi,
                                  onSwitch: (v) =>
                                      setState(() => _isPagi = v),
                                ),
                                const SizedBox(height: AppLayout.cardGap),
                                _ActivesCard(
                                  rec: rec,
                                  expanded: _expandZat,
                                  onToggle: () => setState(
                                      () => _expandZat = !_expandZat),
                                ),
                                const SizedBox(height: AppLayout.cardGap),
                                _AvoidCard(rec: rec),
                                const SizedBox(height: AppLayout.cardGap),
                                _MoreCard(rec: rec),
                                const SizedBox(height: AppLayout.cardGap),
                                const _DisclaimerCard(),
                                const SizedBox(height: 8),
                              ],
                            ),
                    ),
                    if (rec != null)
                      _BottomCta(
                        showSave:
                            !widget.archived && !_saved,
                        saving: _saving,
                        onSave: _save,
                        onRescan: () {
                          AppAnalytics.log('result_rescan', {});
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SkinScanPage(
                                  enableCamera: true),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool compact;
  final VoidCallback onBack;
  const _Header({required this.compact, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          compact ? 12 : 16, 12, compact ? 12 : 16, 8),
      child: Row(
        children: [
          SizedBox(
            width: AppLayout.minTouch,
            height: AppLayout.minTouch,
            child: Material(
              color: AppTokens.surface,
              shape: const CircleBorder(),
              child: InkWell(
                key: const Key('result-back'),
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: const Icon(Icons.chevron_left_rounded,
                    color: AppTokens.primary, size: 30),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Hasil Rekomendasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTokens.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppLayout.minTouch),
        ],
      ),
    );
  }
}

class _AccuracyNotice extends StatelessWidget {
  const _AccuracyNotice();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.r12),
        border: Border.all(color: AppTokens.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppTokens.info, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(AppCopy.accuracyLower, style: AppTokens.caption),
          ),
        ],
      ),
    );
  }
}

class _ArchivedNotice extends StatelessWidget {
  const _ArchivedNotice();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTokens.successSoft,
        borderRadius: BorderRadius.circular(AppTokens.r12),
      ),
      child: Text('Hasil scan tersimpan', style: AppTokens.caption),
    );
  }
}

class _UnresolvedNotice extends StatelessWidget {
  const _UnresolvedNotice();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTokens.warnChipBg,
        borderRadius: BorderRadius.circular(AppTokens.r12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppTokens.warnChipText, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Belum dapat ditentukan. Ulangi foto dengan pencahayaan lebih baik.',
              style: AppTokens.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipeCard extends StatelessWidget {
  final SkinRecommendation rec;
  final bool expanded;
  final VoidCallback onToggle;
  const _TipeCard(
      {required this.rec, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final long = rec.penjelasanSingkat.length > 140;
    final text = (!expanded && long)
        ? '${rec.penjelasanSingkat.substring(0, 140)}…'
        : rec.penjelasanSingkat;
    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: AppTokens.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hasil analisis', style: AppTokens.eyebrow),
          const SizedBox(height: 4),
          Text(rec.tipeKulit, style: AppTokens.h1),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(text, style: AppTokens.body),
          ],
          if (long)
            TextButton(
              onPressed: onToggle,
              child: Text(expanded ? 'Tutup' : 'Selengkapnya'),
            ),
        ],
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final SkinRecommendation rec;
  final bool isPagi;
  final ValueChanged<bool> onSwitch;
  const _RoutineCard(
      {required this.rec, required this.isPagi, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final steps = isPagi ? rec.rutinPagi : rec.rutinMalam;
    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: AppTokens.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rutinitas', style: AppTokens.title),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  key: const Key('routine-toggle-pagi'),
                  onPressed: isPagi ? null : () => onSwitch(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: isPagi
                        ? AppTokens.primary
                        : AppTokens.successSoft,
                    foregroundColor:
                        isPagi ? Colors.white : AppTokens.primary,
                    minimumSize: const Size(0, AppLayout.minTouch),
                  ),
                  child: const Text('Pagi'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  key: const Key('routine-toggle-malam'),
                  onPressed: !isPagi ? null : () => onSwitch(false),
                  style: FilledButton.styleFrom(
                    backgroundColor: !isPagi
                        ? AppTokens.primary
                        : AppTokens.successSoft,
                    foregroundColor:
                        !isPagi ? Colors.white : AppTokens.primary,
                    minimumSize: const Size(0, AppLayout.minTouch),
                  ),
                  child: const Text('Malam'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (steps.isEmpty)
            Text('Belum ada langkah. Lakukan scan ulang.',
                style: AppTokens.caption)
          else
            ...steps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppTokens.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(e.value, style: AppTokens.body)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _ActivesCard extends StatelessWidget {
  final SkinRecommendation rec;
  final bool expanded;
  final VoidCallback onToggle;
  const _ActivesCard(
      {required this.rec, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    if (rec.rekomendasi.isEmpty) return const SizedBox.shrink();
    final shown =
        expanded ? rec.rekomendasi : rec.rekomendasi.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: AppTokens.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zat aktif yang cocok', style: AppTokens.title),
          const SizedBox(height: 4),
          ...shown.map((a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.nama,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.ink,
                        )),
                    const SizedBox(height: 2),
                    Text(a.fungsi, style: AppTokens.caption),
                    const Divider(
                        height: 16, color: AppTokens.border),
                  ],
                ),
              )),
          if (rec.rekomendasi.length > 3)
            TextButton(
              key: const Key('zat-lihat-semua'),
              onPressed: onToggle,
              child: Text(expanded ? 'Tutup' : 'Lihat semua'),
            ),
        ],
      ),
    );
  }
}

class _AvoidCard extends StatelessWidget {
  final SkinRecommendation rec;
  const _AvoidCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    if (rec.dihindari.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: AppTokens.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zat aktif yang dihindari', style: AppTokens.title),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rec.dihindari
                .map((z) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTokens.warnChipBg,
                        borderRadius:
                            BorderRadius.circular(AppTokens.r12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 18,
                              color: AppTokens.warnChipText),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              z,
                              style: const TextStyle(
                                color: AppTokens.warnChipText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  final SkinRecommendation rec;
  const _MoreCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTokens.card(),
      child: Column(
        children: [
          if (rec.tambahan.isNotEmpty)
            ExpansionTile(
              title: Text('Perawatan tambahan', style: AppTokens.title),
              shape: const Border(),
              children: rec.tambahan
                  .map((t) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.check_circle_outline_rounded,
                            color: AppTokens.primarySoft, size: 20),
                        title: Text(t, style: AppTokens.body),
                      ))
                  .toList(),
            ),
          if (rec.referensi.isNotEmpty)
            ExpansionTile(
              title: Text('Referensi', style: AppTokens.title),
              subtitle: Text('Rujukan umum, belum diverifikasi',
                  style: AppTokens.caption),
              shape: const Border(),
              children: rec.referensi
                  .map((r) => ListTile(
                        dense: true,
                        title: Text(r.judul, style: AppTokens.body),
                        subtitle: r.tahunAtauPenerbit.isEmpty
                            ? null
                            : Text(r.tahunAtauPenerbit,
                                style: AppTokens.caption),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('disclaimer'),
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppTokens.surfaceWarm,
        borderRadius: BorderRadius.circular(AppTokens.r12),
        border: Border.all(color: AppTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_information_outlined,
              color: AppTokens.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(AppCopy.disclaimer, style: AppTokens.caption),
          ),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  final VoidCallback onRetake;
  const _EmptyBody({required this.onRetake});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_outlined,
                size: 48, color: AppTokens.disabled),
            const SizedBox(height: 12),
            Text('Data tidak tersedia', style: AppTokens.title),
            const SizedBox(height: 6),
            Text('Lakukan scan ulang untuk mendapat rekomendasi.',
                style: AppTokens.caption, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetake,
              child: Text(AppCopy.ctaScanUlang),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final bool showSave;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onRescan;
  const _BottomCta({
    required this.showSave,
    required this.saving,
    required this.onSave,
    required this.onRescan,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: const BoxDecoration(
          color: AppTokens.surface,
          border: Border(top: BorderSide(color: AppTokens.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const Key('scan-ulang'),
                onPressed: onRescan,
                child: Text(AppCopy.ctaScanUlang),
              ),
            ),
            if (showSave) ...[
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const Key('save-result'),
                  onPressed: saving ? null : onSave,
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(AppCopy.ctaSimpanHasil),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
