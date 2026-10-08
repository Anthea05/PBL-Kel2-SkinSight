import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/skin_history_repository.dart';
import '../models/skin_analysis.dart';

class SkinResultPage extends StatelessWidget {
  final Uint8List? selfieBytes;
  final SkinAnalysis? analysis;
  final bool archived;

  const SkinResultPage({
    super.key,
    this.selfieBytes,
    this.analysis,
    this.archived = false,
  });

  static const _teal = Color(0xFF168A78);
  static const _deepTeal = Color(0xFF087467);
  static const _navy = Color(0xFF13263A);
  static const _cream = Color(0xFFFFF8EB);
  static const _coral = Color(0xFFFF6674);
  static const _orange = Color(0xFFFFAB26);
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
                      colors: [Color(0xFFDDF5FF), _cream, Color(0xFFFFFBF3)],
                      stops: [0, .23, 1],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _ResultBackgroundPainter(),
                          ),
                        ),
                      ),
                      CustomScrollView(
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _ResultHeader(
                              compact: compact,
                              onBack: () => Navigator.of(context).pop(),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 12 : 18,
                              6,
                              compact ? 12 : 18,
                              26,
                            ),
                            sliver: SliverList.list(
                              children: [
                                _SelfieCard(
                                  selfieBytes:
                                      analysis?.selfieBytes ?? selfieBytes,
                                  compact: compact,
                                  archived: archived,
                                ),
                                const SizedBox(height: 14),
                                _ScoreCard(
                                  compact: compact,
                                  score: analysis?.score ?? 82,
                                  title:
                                      analysis?.title ?? 'Kombinasi (T-Zone)',
                                ),
                                const SizedBox(height: 14),
                                _IssuesCard(
                                  compact: compact,
                                  oil: analysis?.oil ?? 68,
                                  pores: analysis?.pores ?? 52,
                                  acne: analysis?.acne ?? 46,
                                  redness: analysis?.redness ?? 34,
                                ),
                                const SizedBox(height: 14),
                                _SkinTypeCard(
                                  compact: compact,
                                  skinType: analysis?.skinType ??
                                      'Kombinasi (T-Zone)',
                                ),
                                const SizedBox(height: 14),
                                _ActivesCard(compact: compact),
                                const SizedBox(height: 14),
                                _LifestyleCard(compact: compact),
                                if (!archived) ...[
                                  const SizedBox(height: 18),
                                  _SaveButton(
                                    onTap: () async {
                                      await SkinHistoryRepository.instance
                                          .saveLatest(selfieBytes);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Hasil diagnosis berhasil disimpan ke riwayat.',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
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

class _ResultHeader extends StatelessWidget {
  final bool compact;
  final VoidCallback onBack;

  const _ResultHeader({required this.compact, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(compact ? 14 : 18, 16, compact ? 14 : 18, 10),
      child: Row(
        children: [
          Material(
            color: Colors.white.withValues(alpha: .88),
            shape: const CircleBorder(),
            child: InkWell(
              key: const Key('result-back'),
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: compact ? 44 : 50,
                height: compact ? 44 : 50,
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: SkinResultPage._deepTeal,
                  size: 33,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Hasil Diagnosis',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SkinResultPage._navy,
                fontSize: compact ? 23 : 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: compact ? 44 : 50),
        ],
      ),
    );
  }
}

class _SelfieCard extends StatelessWidget {
  final Uint8List? selfieBytes;
  final bool compact;
  final bool archived;

  const _SelfieCard({
    required this.selfieBytes,
    required this.compact,
    required this.archived,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 230 : 275,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 28 : 34),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: SkinResultPage._deepTeal.withValues(alpha: .12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 24 : 30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (selfieBytes != null)
              Image.memory(
                selfieBytes!,
                key: const Key('captured-selfie'),
                fit: BoxFit.cover,
                gaplessPlayback: true,
              )
            else
              const ColoredBox(
                color: Color(0xFFE9F7F4),
                child: Center(
                  child: Icon(
                    Icons.face_retouching_natural_rounded,
                    size: 76,
                    color: SkinResultPage._teal,
                  ),
                ),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xA6002630)],
                  stops: [.52, 1],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 15,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: SkinResultPage._teal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          archived
                              ? 'Hasil scan tersimpan'
                              : 'Selfie berhasil dianalisis',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Pencahayaan dan posisi wajah sudah sesuai',
                          style: TextStyle(
                            color: Color(0xFFD8ECEE),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final bool compact;
  final int score;
  final String title;

  const _ScoreCard({
    required this.compact,
    required this.score,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return _ResultCard(
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: Row(
        children: [
          Container(
            width: compact ? 96 : 112,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F7F2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'Skor Kulit',
                  style: TextStyle(
                    color: SkinResultPage._deepTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '$score',
                  style: const TextStyle(
                    height: 1.05,
                    color: SkinResultPage._deepTeal,
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  '/100',
                  style: TextStyle(color: Color(0xFF559B92)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDFBEA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    score >= 80
                        ? '✨ Kondisi Kulit Baik'
                        : score >= 70
                            ? '✨ Kondisi Cukup Baik'
                            : '✨ Perlu Perhatian',
                    style: const TextStyle(
                      color: SkinResultPage._deepTeal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$title. Tetap jaga rutinitas perawatan dan pola hidup agar kondisi kulit makin stabil.',
                  style: TextStyle(
                    color: SkinResultPage._navy.withValues(alpha: .80),
                    fontSize: compact ? 13 : 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IssuesCard extends StatelessWidget {
  final bool compact;
  final int oil;
  final int pores;
  final int acne;
  final int redness;

  const _IssuesCard({
    required this.compact,
    required this.oil,
    required this.pores,
    required this.acne,
    required this.redness,
  });

  @override
  Widget build(BuildContext context) {
    return _ResultCard(
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Masalah Ditemukan'),
          const SizedBox(height: 15),
          _IssueBar(
            label: 'Berminyak (Sebum)',
            value: oil,
            status: _statusFor(oil),
            color: SkinResultPage._teal,
          ),
          const _IssueDivider(),
          _IssueBar(
            label: 'Pori-Pori Besar',
            value: pores,
            status: _statusFor(pores),
            color: SkinResultPage._orange,
          ),
          const _IssueDivider(),
          _IssueBar(
            label: 'Jerawat Aktif',
            value: acne,
            status: _statusFor(acne),
            color: Color(0xFFD79825),
          ),
          const _IssueDivider(),
          _IssueBar(
            label: 'Kemerahan',
            value: redness,
            status: _statusFor(redness),
            color: SkinResultPage._coral,
          ),
        ],
      ),
    );
  }
}

class _IssueBar extends StatelessWidget {
  final String label;
  final int value;
  final String status;
  final Color color;

  const _IssueBar({
    required this.label,
    required this.value,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: SkinResultPage._navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: value / 100,
                  color: color,
                  backgroundColor: const Color(0xFFECEFF0),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$value%',
                style: const TextStyle(
                  color: SkinResultPage._navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(status, style: const TextStyle(color: Color(0xFF718392))),
            ],
          ),
        ),
      ],
    );
  }
}

class _IssueDivider extends StatelessWidget {
  const _IssueDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 25, color: Color(0xFFE3E8E9));
  }
}

class _SkinTypeCard extends StatelessWidget {
  final bool compact;
  final String skinType;

  const _SkinTypeCard({required this.compact, required this.skinType});

  @override
  Widget build(BuildContext context) {
    return _ResultCard(
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Jenis Kulit'),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(skinType, highlighted: true),
              if (skinType != 'Cenderung Berminyak')
                const _Pill('Cenderung Berminyak'),
              if (skinType != 'Sensitif Ringan') const _Pill('Sensitif Ringan'),
              if (skinType != 'Rentan Berjerawat')
                const _Pill('Rentan Berjerawat'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivesCard extends StatelessWidget {
  final bool compact;

  const _ActivesCard({required this.compact});

  @override
  Widget build(BuildContext context) {
    return _ResultCard(
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Panduan Zat Aktif'),
          SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill('Niacinamide 5%', highlighted: true),
              _Pill('Salicylic Acid 1%', highlighted: true),
              _Pill('Hyaluronic Acid', outlined: true),
              _Pill('Centella Asiatica', outlined: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifestyleCard extends StatelessWidget {
  final bool compact;

  const _LifestyleCard({required this.compact});

  @override
  Widget build(BuildContext context) {
    return _ResultCard(
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Saran Gaya Hidup'),
          SizedBox(height: 12),
          _AdviceTile(
            title: 'Perawatan Lembut',
            subtitle: 'Cleanser pH 5.5, hindari scrub kasar.',
          ),
          SizedBox(height: 8),
          _AdviceTile(
            title: 'Hidrasi 2L / hari',
            subtitle: 'Air cukup membantu menekan produksi minyak.',
          ),
        ],
      ),
    );
  }
}

class _AdviceTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AdviceTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F7),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SkinResultPage._navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF6D8190)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: SkinResultPage._navy),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool highlighted;
  final bool outlined;

  const _Pill(this.text, {this.highlighted = false, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFFDDF5EF)
            : outlined
                ? Colors.white
                : const Color(0xFFF1F3F3),
        borderRadius: BorderRadius.circular(22),
        border: outlined ? Border.all(color: const Color(0xFFD8E0E1)) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: highlighted
              ? SkinResultPage._deepTeal
              : SkinResultPage._navy.withValues(alpha: .70),
          fontWeight: highlighted ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: SkinResultPage._navy,
        fontSize: 23,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ResultCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: SkinResultPage._teal.withValues(alpha: .06)),
        boxShadow: [
          BoxShadow(
            color: SkinResultPage._navy.withValues(alpha: .07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('save-result'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Ink(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [SkinResultPage._teal, SkinResultPage._deepTeal],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Center(
            child: Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultBackgroundPainter extends CustomPainter {
  const _ResultBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: .65);
    canvas.drawCircle(Offset(size.width * .12, 105), 24, bubblePaint);
    canvas.drawCircle(Offset(size.width * .82, 72), 15, bubblePaint);
    canvas.drawCircle(Offset(size.width * .25, 155), 11, bubblePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _statusFor(int value) {
  if (value >= 65) return 'Tinggi';
  if (value >= 40) return 'Sedang';
  return 'Rendah';
}
