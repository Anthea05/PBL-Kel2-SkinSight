import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/skin_history_repository.dart';
import '../models/profile_data.dart';
import '../models/skin_analysis.dart';
import '../theme/app_layout.dart';
import '../theme/app_tokens.dart';
import 'skin_help_page.dart';
import 'skin_quiz_page.dart';

class SkinHomePage extends StatelessWidget {
  const SkinHomePage({super.key});

  static const String assetBase = 'lib/assets/images';
  static const Color green = AppTokens.teal;
  static const Color deepGreen = AppTokens.deepTeal;
  static const Color cream = AppTokens.cream;
  static const Color navy = AppTokens.navy;
  static const Color coral = AppTokens.coral;
  static const Color orange = AppTokens.orange;
  static const Color sky = AppTokens.sky;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, screen) {
            final w = screen.maxWidth;
            final isTablet = AppLayout.isTablet(w);
            final contentMax = AppLayout.contentMax(w);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMax),
                child: Column(
                  children: [
                    Expanded(
                        child: _HomeScrollView(isTablet: isTablet)),
                    _BottomNavWrap(isTablet: isTablet),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BottomNavWrap extends StatelessWidget {
  final bool isTablet;
  const _BottomNavWrap({this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final hPad = AppLayout.marginFor(c.maxWidth);
        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
          child: _BottomNav(isTablet: isTablet),
        );
      },
    );
  }
}

class _HomeScrollView extends StatelessWidget {
  final bool isTablet;
  const _HomeScrollView({this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        // Di tablet, constraints sudah max 720 — compact tidak berlaku.
        final compact =
            !isTablet && AppLayout.isCompact(screenW);
        final hPad = AppLayout.marginFor(
            isTablet ? AppLayout.wideBreakpoint : screenW);
        return CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
                child: _Hero(
                    compact: compact, isTablet: isTablet)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 8),
                child: Column(
                  children: [
                    _ActivityHeader(
                        compact: compact, isTablet: isTablet),
                    const SizedBox(height: 12),
                    if (isTablet)
                      Container(
                        key: const Key('home-tablet-duo'),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _ScanCard(
                                    compact: false)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  key:
                                      const Key('open-history'),
                                  onTap: () =>
                                      Navigator.of(context)
                                          .pushNamed('/history'),
                                  borderRadius:
                                      BorderRadius.circular(
                                          AppTokens.r16),
                                  child: _HistoryCard(
                                      compact: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _ScanCard(compact: compact),
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const Key('open-history'),
                          onTap: () => Navigator.of(context)
                              .pushNamed('/history'),
                          borderRadius: BorderRadius.circular(
                              AppTokens.r16),
                          child:
                              _HistoryCard(compact: compact),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Hero responsif: HP kompak → standar → tablet ──
class _Hero extends StatelessWidget {
  final bool compact;
  final bool isTablet;
  const _Hero({required this.compact, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final hPad = isTablet ? 22.0 : (compact ? 14.0 : 16.0);
    final titleH = isTablet ? 62.0 : (compact ? 44.0 : 52.0);
    final imgW = isTablet ? 190.0 : (compact ? 118.0 : 136.0);
    final imgH = isTablet ? 210.0 : (compact ? 138.0 : 156.0);
    final scale = isTablet ? 1.12 : (compact ? 0.94 : 1.0);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F4F0), AppTokens.cream],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppTokens.r20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 14),
      child: Column(
        children: [
          _Header(compact: compact, isTablet: isTablet),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      '${SkinHomePage.assetBase}/skin_analyze_title.png',
                      height: titleH,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kulit sehat cerminan kesehatan menyeluruh.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.caption
                          .copyWith(fontSize: 12 * scale),
                    ),
                    const SizedBox(height: 10),
                    _TryNow(
                        compact: compact,
                        isTablet: isTablet),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: imgW,
                height: imgH,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      '${SkinHomePage.assetBase}/skin_girl.png',
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      width: isTablet
                          ? 96.0
                          : (compact ? 62.0 : 72.0),
                      child: Image.asset(
                        '${SkinHomePage.assetBase}/skin_magnifier.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool compact;
  final bool isTablet;
  const _Header({required this.compact, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileData>();
    final avatarSize = isTablet
        ? 46.0
        : (compact ? 38.0 : 42.0);
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('open-profile'),
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile'),
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EF),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white, width: 2),
                    ),
                    child: profile.photoBytes == null
                        ? Center(
                            child: Text(
                              _profileInitials(profile.name),
                              style: const TextStyle(
                                color: AppTokens.deepTeal,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : Image.memory(
                            profile.photoBytes!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning,',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTokens.caption
                              .copyWith(fontSize: 11),
                        ),
                        Text(
                          profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w800,
                            color: AppTokens.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTokens.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppTokens.deepTeal
                    .withValues(alpha: .06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: AppTokens.deepTeal,
                ),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5C63),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _profileInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return 'AK';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

class _TryNow extends StatelessWidget {
  final bool compact;
  final bool isTablet;
  const _TryNow({required this.compact, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final buttonHeight =
        isTablet ? 52.0 : (compact ? 42.0 : 46.0);
    final circleSize =
        isTablet ? 40.0 : (compact ? 30.0 : 36.0);
    final iconSize =
        isTablet ? 22.0 : (compact ? 18.0 : 20.0);
    final fontSize =
        isTablet ? 15.0 : (compact ? 13.0 : 14.0);
    final gap = compact ? 6.0 : 8.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('open-quiz-try'),
        onTap: () => _openQuiz(context),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: buttonHeight,
          constraints: const BoxConstraints(minWidth: 48),
          padding: EdgeInsets.only(
            left: compact && !isTablet ? 12 : 14,
            right: 5,
          ),
          decoration: BoxDecoration(
            gradient: AppTokens.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTokens.buttonShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Mulai scan',
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
                    ),
                  ),
                ),
              ),
              SizedBox(width: gap),
              Container(
                width: circleSize,
                height: circleSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTokens.deepTeal,
                  size: iconSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  final bool compact;
  final bool isTablet;
  const _ActivityHeader(
      {required this.compact, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Aktivitas Kulit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w800,
              color: AppTokens.navy,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('open-history-all'),
            onTap: () =>
                Navigator.of(context).pushNamed('/history'),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 4, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Semua',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTokens.deepTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTokens.deepTeal,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanCard extends StatefulWidget {
  final bool compact;
  const _ScanCard({required this.compact});

  @override
  State<_ScanCard> createState() => _ScanCardState();
}

class _ScanCardState extends State<_ScanCard> {
  late Future<List<SkinAnalysis>> _future;
  VoidCallback? _revisionListener;

  @override
  void initState() {
    super.initState();
    final repo = SkinHistoryRepository.instance;
    _future = repo.fetchHistory(newestFirst: true);
    _revisionListener = () {
      if (!mounted) return;
      setState(() {
        _future = repo.fetchHistory(newestFirst: true);
      });
    };
    repo.revision.addListener(_revisionListener!);
  }

  @override
  void dispose() {
    if (_revisionListener != null) {
      SkinHistoryRepository.instance.revision
          .removeListener(_revisionListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SkinAnalysis>>(
      future: _future,
      builder: (context, snapshot) {
        final latest = snapshot.data?.isNotEmpty == true
            ? snapshot.data!.first
            : null;
        return _ScanCardContent(
          compact: widget.compact,
          analysis: latest,
        );
      },
    );
  }
}

class _ScanCardContent extends StatelessWidget {
  final bool compact;
  final SkinAnalysis? analysis;
  const _ScanCardContent(
      {required this.compact, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 40.0 : 44.0;
    final gap = compact ? 8.0 : 10.0;
    final titleSize = compact ? 14.0 : 15.0;
    final scoreSize = compact ? 22.0 : 26.0;
    final score = analysis?.score ?? 82;
    final oil = analysis?.oil ?? 68;
    final redness = analysis?.redness ?? 34;
    final hydration = analysis?.hydration ?? 78;
    final dateLabel = analysis == null
        ? 'Kemarin, 20:15'
        : _formatScanDate(analysis!.analyzedAt);
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.r16),
        border: Border.all(color: AppTokens.cardBorder),
        boxShadow: AppTokens.cardShadowSoft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  gradient: AppTokens.primarySoftGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.center_focus_strong_rounded,
                  color: Colors.white,
                  size: compact ? 22 : 24,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Terakhir',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppTokens.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF829194),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: gap),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      maxLines: 1,
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$score',
                            style: TextStyle(
                              fontSize: scoreSize,
                              height: 1,
                              color: AppTokens.deepTeal,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(
                            text: '/100',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: _HealthBadge(
                        compact: compact,
                        score: score,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE4E8E7)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child:
                    _Metric('Kemerahan', redness, Color(0xFFFF6470)),
              ),
              _Rule(),
              Expanded(
                child: _Metric('Minyak', oil, Color(0xFFFFB131)),
              ),
              _Rule(),
              Expanded(
                child: _Metric('Hidrasi', hydration, Color(0xFF2DA6F2)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final bool compact;
  final int score;
  const _HealthBadge({this.compact = false, this.score = 82});

  String get _label {
    if (score >= 80) return 'Kondisi Kulit Baik';
    if (score >= 70) return 'Kondisi Cukup Baik';
    return 'Perlu Perhatian';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF6E7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 10,
            color: AppTokens.orange,
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            maxLines: 1,
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              color: AppTokens.deepTeal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Metric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  label == 'Kemerahan'
                      ? Icons.blur_on_rounded
                      : label == 'Minyak'
                          ? Icons.water_drop_outlined
                          : Icons.spa_outlined,
                  color: color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      '$value%',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTokens.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: value / 100,
              backgroundColor: color.withValues(alpha: .15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE0E7E5),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final bool compact;
  const _HistoryCard({required this.compact});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  late Future<List<SkinAnalysis>> _future;
  VoidCallback? _revisionListener;

  @override
  void initState() {
    super.initState();
    final repo = SkinHistoryRepository.instance;
    _future = repo.fetchLatest(count: 7);
    _revisionListener = () {
      if (!mounted) return;
      setState(() {
        _future = repo.fetchLatest(count: 7);
      });
    };
    repo.revision.addListener(_revisionListener!);
  }

  @override
  void dispose() {
    if (_revisionListener != null) {
      SkinHistoryRepository.instance.revision
          .removeListener(_revisionListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    return FutureBuilder<List<SkinAnalysis>>(
      future: _future,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <SkinAnalysis>[];
        final scores = items.isEmpty
            ? const [35.0, 47.0, 59.0, 50.0, 57.0, 68.0, 82.0]
            : items.reversed.map((e) => e.score.toDouble()).toList();
        final countLabel = items.isEmpty
            ? '7 scan bulan ini  '
            : '${items.length} scan terakhir  ';
        final delta = items.length >= 2
            ? items.first.score - items.last.score
            : 6;
        final deltaLabel = delta >= 0 ? '+$delta poin' : '$delta poin';
        return Container(
          height: compact ? 142 : 152,
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(AppTokens.r16),
            border: Border.all(color: AppTokens.cardBorder),
            boxShadow: AppTokens.cardShadowSoft,
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: compact ? 108 : 128,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _HistoryIcon(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Riwayat Perubahan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTokens.navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text.rich(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: countLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF819093),
                                      ),
                                    ),
                                    TextSpan(
                                      text: deltaLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTokens.deepTeal,
                                        fontWeight: FontWeight.w800,
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
                  ],
                ),
              ),
              Positioned(
                left: 4,
                bottom: 0,
                child: _Bars(values: scores),
              ),
          Positioned(
            right: 0,
            bottom: -6,
            width: compact ? 104 : 118,
            height: compact ? 104 : 118,
            child: Image.asset(
              '${SkinHomePage.assetBase}/cat_happy.png',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 12,
            top: 34,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF55C69E), AppTokens.teal],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.teal
                        .withValues(alpha: .3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'KULITMU\nMAKIN SEHAT!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  height: 1.1,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}

class _HistoryIcon extends StatelessWidget {
  const _HistoryIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppTokens.primarySoftGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.trending_up_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  final List<double> values;
  const _Bars({this.values = const [35.0, 47.0, 59.0, 50.0, 57.0, 68.0, 82.0]});

  @override
  Widget build(BuildContext context) {
    final shown = values.length > 7 ? values.sublist(values.length - 7) : values;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(shown.length, (i) {
        return Container(
          width: 10,
          height: (shown[i].clamp(5, 100)) * .52,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            gradient: i == shown.length - 1
                ? AppTokens.primaryGradient
                : null,
            color: i == shown.length - 1
                ? null
                : AppTokens.teal.withValues(alpha: .18 + i * .09),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        );
      }),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final bool isTablet;
  const _BottomNav({this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.r20),
        border: Border.all(color: AppTokens.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppTokens.deepTeal.withValues(alpha: .08),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              const _NavItem(Icons.home_rounded, 'Beranda', true),
              _NavItem(
                Icons.help_outline_rounded,
                'Bantuan',
                false,
                key: const Key('open-help'),
                onTap: () => _openHelp(context),
              ),
            ],
          ),
          Positioned(
            top: -14,
            child: GestureDetector(
              key: const Key('open-quiz-scan'),
              onTap: () => _openQuiz(context),
              child: Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTokens.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppTokens.buttonShadow,
                  ),
                  child: const Icon(
                    Icons.center_focus_strong_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem(this.icon, this.label, this.selected,
      {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppTokens.deepTeal : const Color(0xFF78878A);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openQuiz(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const SkinQuizPage()),
  );
}

void _openHelp(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const SkinHelpPage()),
  );
}

const _shortMonths = [
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

String _formatScanDate(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(value.year, value.month, value.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Hari ini, $hour:$minute';
  if (diff == 1) return 'Kemarin, $hour:$minute';
  return '${value.day} ${_shortMonths[value.month - 1]} · $hour:$minute';
}
