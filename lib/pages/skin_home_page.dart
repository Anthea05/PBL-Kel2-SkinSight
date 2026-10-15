import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/shimmer_skeleton.dart';
import '../data/skin_journey_store.dart';
import '../data/skin_notification_center.dart';
import 'skin_progress_page.dart';
import 'package:provider/provider.dart';

import '../models/profile_data.dart';
import '../widgets/skin_bottom_nav.dart';
import 'skin_about_page.dart';
import 'skin_education_page.dart';
import 'skin_help_page.dart';
import 'skin_notifications_page.dart';
import 'skin_quiz_page.dart';
import 'skin_scan_page.dart';

class SkinHomePage extends StatefulWidget {
  final int initialIndex;

  const SkinHomePage({super.key, this.initialIndex = 0});

  static const String assetBase = 'lib/assets/images';
  static const Color green = Color(0xFF168A78);
  static const Color deepGreen = Color(0xFF087467);
  static const Color cream = Color(0xFFFFF8EB);
  static const Color navy = Color(0xFF182A35);
  static const Color coral = Color(0xFFFF6B70);
  static const Color orange = Color(0xFFFFB43B);
  static const Color sky = Color(0xFF35A9EE);

  @override
  State<SkinHomePage> createState() => _SkinHomePageState();
}

/// Menjaga tampilan Home lama dan footer empat tab dari versi baru.
/// Tab memakai IndexedStack agar tidak dihancurkan setiap berpindah menu.
class _SkinHomePageState extends State<SkinHomePage> {
  late int _currentIndex;
  // Cache first-open skeleton status across Home route instances.
  static final Set<int> _loaded = <int>{};
  Timer? _firstLoad;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
    _startFirstLoad();
  }

  void _startFirstLoad() {
    if (_loaded.contains(_currentIndex)) return;
    _firstLoad?.cancel();
    // First opening of each tab only. The four tabs remain alive afterward.
    _firstLoad = Timer(const Duration(milliseconds: 260), () {
      if (mounted) setState(() => _loaded.add(_currentIndex));
    });
  }

  @override
  void dispose() {
    _firstLoad?.cancel();
    super.dispose();
  }

  void _selectTab(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    _startFirstLoad();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SkinHomePage.cream,
        body: SafeArea(
            bottom: false,
            child: Center(
                child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SizedBox.expand(
                  child: Stack(children: [
                IndexedStack(index: _currentIndex, children: const [
                  _HomeScrollView(key: PageStorageKey('home-tab')),
                  SkinEducationPage(
                    embedded: true,
                    key: PageStorageKey('education-tab'),
                  ),
                  SkinHelpPage(embedded: true, key: PageStorageKey('help-tab')),
                  SkinAboutPage(
                      embedded: true, key: PageStorageKey('about-tab')),
                ]),
                if (!_loaded.contains(_currentIndex))
                  Positioned.fill(
                    child: ColoredBox(
                      color: SkinHomePage.cream,
                      child: ShimmerLoading(
                          child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: const [
                          SkeletonBox(height: 135),
                          SizedBox(height: 20),
                          SkeletonBox(width: 170, height: 24),
                          SizedBox(height: 18),
                          SkeletonBox(height: 115),
                          SizedBox(height: 12),
                          SkeletonBox(height: 115)
                        ],
                      )),
                    ),
                  ),
              ])),
            ))),
        bottomNavigationBar: SkinBottomNav(
          currentIndex: _currentIndex,
          onSelected: _selectTab,
        ),
      );
}

class _HomeScrollView extends StatelessWidget {
  const _HomeScrollView({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 350;
      final h = (constraints.maxWidth / 390).clamp(.84, 1.18);
      final horizontal = compact ? 15.0 : 20.0;
      return CustomScrollView(physics: const ClampingScrollPhysics(), slivers: [
        SliverToBoxAdapter(child: _Hero(scale: h)),
        SliverToBoxAdapter(
            child: Transform.translate(
          offset: const Offset(0, -12),
          child: Container(
            padding: EdgeInsets.fromLTRB(horizontal, 27, horizontal, 28),
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      SkinHomePage.cream,
                      Color(0xFFFFFAF0),
                      Color(0xFFF4F8EC),
                    ]),
                borderRadius:
                    BorderRadius.vertical(top: Radius.elliptical(220, 28))),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkinJourneyCard(),
                  SizedBox(height: 26),
                  _RecentActivitySection(),
                  SizedBox(height: 22),
                ]),
          ),
        )),
      ]);
    });
  }
}

class _Hero extends StatelessWidget {
  final double scale;
  const _Hero({required this.scale});
  @override
  Widget build(BuildContext context) {
    final h = 334 * scale;
    return SizedBox(
        height: h,
        child: Stack(clipBehavior: Clip.hardEdge, children: [
          const Positioned.fill(
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                Color(0xFF14BDF0),
                Color(0xFF5ED6F3),
                Color(0xFFE7F7EE),
              ],
                          stops: [
                0,
                .67,
                1
              ])))),
          const Positioned.fill(child: _HeroDecorations()),
          const Positioned(
              left: 0,
              right: 0,
              bottom: -1,
              height: 54,
              child: _SkinLayerTransition()),
          Positioned(
              left: 20 * scale,
              right: 20 * scale,
              top: 15 * scale,
              child: _Header(scale: scale)),
          Positioned(
              left: 16 * scale,
              top: 96 * scale,
              width: 176 * scale,
              height: 132 * scale,
              child: Image.asset(
                  '${SkinHomePage.assetBase}/skin_analyze_title.png',
                  fit: BoxFit.contain)),
          Positioned(
              key: const Key('home-skin-girl'),
              top: 70 * scale,
              right: 4 * scale,
              width: 158 * scale,
              height: 218 * scale,
              child: Image.asset('${SkinHomePage.assetBase}/skin_girl.png',
                  fit: BoxFit.contain)),
          Positioned(
              bottom: 55 * scale,
              left: 22 * scale,
              width: 218 * scale,
              child: _JourneyButton(scale: scale)),
        ]));
  }
}

class _JourneyButton extends StatelessWidget {
  final double scale;
  const _JourneyButton({required this.scale});
  @override
  Widget build(BuildContext context) => Material(
        color: SkinHomePage.green,
        borderRadius: BorderRadius.circular(35),
        child: InkWell(
          key: const Key('open-skin-journey'),
          borderRadius: BorderRadius.circular(35),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => SkinJourneyStore.instance.questionnaireDone
                  ? const SkinScanPage()
                  : const SkinQuizPage())),
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 19 * scale, vertical: 12 * scale),
              child: Row(children: [
                const Expanded(
                    child: Text('Mulai Scan',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white))),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ])),
        ),
      );
}

class _HeroDecorations extends StatelessWidget {
  const _HeroDecorations();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / 390;

        return Stack(
          children: [
            Positioned(
              left: 18 * scale,
              top: 72 * scale,
              width: 96 * scale,
              height: 66 * scale,
              child: const _MoleculeCluster(),
            ),
            Positioned(
              left: 172 * scale,
              top: 76 * scale,
              width: 52 * scale,
              height: 52 * scale,
              child: const _Bubble(),
            ),
            Positioned(
              left: 125 * scale,
              top: 69 * scale,
              width: 24 * scale,
              height: 24 * scale,
              child: const _DropletAccent(color: Color(0x66FFFFFF)),
            ),
            Positioned(
              right: 18 * scale,
              top: 118 * scale,
              width: 33 * scale,
              height: 33 * scale,
              child: const _Bubble(),
            ),
            Positioned(
              left: 8 * scale,
              top: 185 * scale,
              width: 46 * scale,
              height: 46 * scale,
              child: const _FaceScanMotif(),
            ),
            Positioned(
              left: 154 * scale,
              top: 130 * scale,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 19 * scale,
                color: SkinHomePage.orange.withValues(alpha: .82),
              ),
            ),
            Positioned(
              left: 2 * scale,
              bottom: 36 * scale,
              width: 78 * scale,
              height: 76 * scale,
              child: Opacity(opacity: .58, child: const _SkinLayerMotif()),
            ),
            Positioned(
              right: 8 * scale,
              bottom: 42 * scale,
              width: 72 * scale,
              height: 76 * scale,
              child: const Opacity(
                opacity: .55,
                child: _MoleculeCluster(),
              ),
            ),
            Positioned(
              right: 72 * scale,
              bottom: 38 * scale,
              width: 22 * scale,
              height: 22 * scale,
              child: const _DropletAccent(color: Color(0x552DA6F2)),
            ),
          ],
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: .72), width: 2),
        gradient: RadialGradient(
          center: const Alignment(-.35, -.45),
          colors: [
            Colors.white.withValues(alpha: .88),
            const Color(0xFFDDBDFF).withValues(alpha: .62),
            const Color(0xFF65DBF5).withValues(alpha: .42),
          ],
        ),
      ),
    );
  }
}

class _MoleculeCluster extends StatelessWidget {
  const _MoleculeCluster();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _MoleculePainter());
  }
}

class _MoleculePainter extends CustomPainter {
  const _MoleculePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: .44)
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke;
    final nodePaint = Paint()
      ..color = Colors.white.withValues(alpha: .62)
      ..style = PaintingStyle.fill;
    final tealNodePaint = Paint()
      ..color = SkinHomePage.deepGreen.withValues(alpha: .20)
      ..style = PaintingStyle.fill;

    final points = <Offset>[
      Offset(size.width * .18, size.height * .57),
      Offset(size.width * .42, size.height * .20),
      Offset(size.width * .66, size.height * .48),
      Offset(size.width * .84, size.height * .17),
      Offset(size.width * .80, size.height * .80),
    ];
    for (final connection in const <(int, int)>[
      (0, 1),
      (1, 2),
      (2, 3),
      (2, 4),
    ]) {
      canvas.drawLine(points[connection.$1], points[connection.$2], linePaint);
    }
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        size.shortestSide * (i == 2 ? .095 : .065),
        i == 2 ? tealNodePaint : nodePaint,
      );
      canvas.drawCircle(
        points[i],
        size.shortestSide * (i == 2 ? .095 : .065),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DropletAccent extends StatelessWidget {
  final Color color;

  const _DropletAccent({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.water_drop_rounded,
      color: color,
      shadows: [
        Shadow(
          color: Colors.white.withValues(alpha: .48),
          blurRadius: 5,
        ),
      ],
    );
  }
}

class _FaceScanMotif extends StatelessWidget {
  const _FaceScanMotif();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: .45)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.face_retouching_natural,
            color: Colors.white.withValues(alpha: .38),
            size: 25,
          ),
          Icon(
            Icons.center_focus_weak_rounded,
            color: Colors.white.withValues(alpha: .72),
            size: 36,
          ),
        ],
      ),
    );
  }
}

class _SkinLayerMotif extends StatelessWidget {
  const _SkinLayerMotif();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _SkinLayerMotifPainter());
  }
}

class _SkinLayerMotifPainter extends CustomPainter {
  const _SkinLayerMotifPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      SkinHomePage.cream.withValues(alpha: .76),
      SkinHomePage.coral.withValues(alpha: .36),
      SkinHomePage.orange.withValues(alpha: .28),
    ];
    for (var i = 0; i < colors.length; i++) {
      final top = size.height * (.18 + i * .20);
      final path = Path()
        ..moveTo(0, top)
        ..quadraticBezierTo(
          size.width * .25,
          top - size.height * .10,
          size.width * .50,
          top,
        )
        ..quadraticBezierTo(
          size.width * .76,
          top + size.height * .10,
          size.width,
          top - size.height * .02,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.height * .13
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SkinLayerTransition extends StatelessWidget {
  const _SkinLayerTransition();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _SkinLayerTransitionPainter());
  }
}

class _SkinLayerTransitionPainter extends CustomPainter {
  const _SkinLayerTransitionPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final coral = Paint()
      ..color = SkinHomePage.coral.withValues(alpha: .20)
      ..style = PaintingStyle.fill;
    final warm = Paint()
      ..color = SkinHomePage.orange.withValues(alpha: .16)
      ..style = PaintingStyle.fill;
    final cream = Paint()
      ..color = SkinHomePage.cream
      ..style = PaintingStyle.fill;

    final coralPath = Path()
      ..moveTo(0, 22)
      ..cubicTo(size.width * .20, 5, size.width * .40, 32, size.width * .60, 16)
      ..cubicTo(size.width * .76, 4, size.width * .90, 25, size.width, 13)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(coralPath, coral);

    final warmPath = Path()
      ..moveTo(0, 29)
      ..cubicTo(
          size.width * .24, 13, size.width * .42, 38, size.width * .65, 23)
      ..cubicTo(size.width * .80, 13, size.width * .92, 32, size.width, 21)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(warmPath, warm);

    final creamPath = Path()
      ..moveTo(0, 36)
      ..cubicTo(
          size.width * .21, 23, size.width * .42, 44, size.width * .63, 31)
      ..cubicTo(size.width * .79, 21, size.width * .91, 39, size.width, 30)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(creamPath, cream);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Header extends StatelessWidget {
  final double scale;

  const _Header({required this.scale});

  @override
  Widget build(BuildContext context) {
    final avatarSize = 46 * scale;
    final profile = context.watch<ProfileData>();

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: 'Buka profil ${profile.name}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('open-profile'),
                onTap: () => Navigator.of(context).pushNamed('/profile'),
                borderRadius: BorderRadius.circular(28 * scale),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 3 * scale),
                  child: Row(
                    children: [
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: profile.photoBytes == null
                            ? Padding(
                                padding: EdgeInsets.all(2 * scale),
                                child: Image.asset(
                                  '${SkinHomePage.assetBase}/start_avatar.png',
                                  key: const Key('home-default-avatar'),
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              )
                            : Image.memory(
                                profile.photoBytes!,
                                key: const Key('home-profile-photo'),
                                width: avatarSize,
                                height: avatarSize,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning,',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12 * scale,
                                color: const Color(0xFF29363A),
                              ),
                            ),
                            Text(
                              profile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 19 * scale,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF11191B),
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
          ),
        ),
        SizedBox(width: 8 * scale),
        AnimatedBuilder(
          animation: Listenable.merge([
            SkinJourneyStore.instance,
            SkinNotificationCenter.instance,
          ]),
          builder: (context, _) {
            final notifications =
                SkinNotificationFeed.build(SkinJourneyStore.instance);
            final hasUnread = notifications.any(
              (item) => !SkinNotificationCenter.instance.isRead(item.id),
            );
            return Semantics(
              button: true,
              label: hasUnread
                  ? 'Buka notifikasi, ada yang belum dibaca'
                  : 'Buka notifikasi',
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      key: const Key('open-notifications'),
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SkinNotificationsPage(),
                        ),
                      ),
                      child: SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 25 * scale,
                          color: SkinHomePage.deepGreen,
                        ),
                      ),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 4,
                      right: 5,
                      child: Container(
                        key: const Key('home-notification-unread-dot'),
                        width: 9 * scale,
                        height: 9 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B70),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Satu akses pemantauan di Home. Tidak ada kartu check-in / aktivitas ganda.
class _SkinJourneyCard extends StatelessWidget {
  const _SkinJourneyCard();

  @override
  Widget build(BuildContext context) {
    final store = SkinJourneyStore.instance;
    return AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final due = store.hasCheckinDue;
          final hasBaseline = store.hasBaseline;
          final next = store.nextCheckin;
          final nextLabel =
              next == null ? '' : '${next.day}/${next.month}/${next.year}';
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              key: const Key('home-open-skin-journey'),
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const SkinProgressPage())),
              child: Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD9E9E2)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 68,
                              height: 68,
                              child: Image.asset(
                                '${SkinHomePage.assetBase}/cat_happy.png',
                                key: const Key('home-journey-cat'),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  const Text('Skin Journey',
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w900,
                                          color: SkinHomePage.navy)),
                                  const SizedBox(height: 4),
                                  Text(
                                      hasBaseline
                                          ? 'Lihat perjalanan dan riwayat kulitmu'
                                          : 'Mulai catat perjalanan kulitmu',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          height: 1.3,
                                          color: Color(0xFF667B7D))),
                                ])),
                            const Icon(Icons.chevron_right_rounded,
                                color: SkinHomePage.deepGreen, size: 26),
                          ]),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF0F8F5),
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          Icon(
                              due
                                  ? Icons.notifications_active_outlined
                                  : Icons.calendar_month_outlined,
                              color: SkinHomePage.deepGreen,
                              size: 21),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(
                                  !hasBaseline
                                      ? 'Scan awal untuk membuka grafik dan timeline'
                                      : due
                                          ? 'Check-in minggu ini sudah tersedia'
                                          : 'Check-in berikutnya: $nextLabel',
                                  style: const TextStyle(
                                      color: SkinHomePage.navy,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600))),
                          if (due)
                            const Text('Mulai →',
                                style: TextStyle(
                                    color: SkinHomePage.deepGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                        ]),
                      ),
                      if (hasBaseline) ...[
                        const SizedBox(height: 13),
                        Text(
                            '${store.photos.length} foto tersimpan  ·  '
                            '${store.checkins.length} check-in',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF667B7D))),
                      ],
                    ]),
              ),
            ),
          );
        });
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    final store = SkinJourneyStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final activities = _latestActivities(store);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(
                color: SkinHomePage.navy,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              const _EmptyActivity()
            else
              SizedBox(
                height: 142,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth =
                        (constraints.maxWidth * .79).clamp(224.0, 300.0);
                    return ListView.separated(
                      key: const Key('recent-activity-list'),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: activities.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => KeyedSubtree(
                        key:
                            ValueKey('recent-activity-${activities[index].id}'),
                        child: SizedBox(
                          width: cardWidth,
                          child: _ActivityCard(activity: activities[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  List<_RecentActivity> _latestActivities(SkinJourneyStore store) {
    final activities = <_RecentActivity>[];
    final photosInCheckins =
        store.checkins.expand((checkin) => checkin.photoIds).toSet();

    for (final checkin in store.checkins) {
      final conditions = checkin.perClass.keys.toList();
      final conditionLabel = conditions.isEmpty
          ? 'Laporan rutin kulitmu berhasil disimpan.'
          : '${conditions.take(2).join(' & ')}${conditions.length > 2 ? ' +${conditions.length - 2}' : ''} diperbarui.';
      activities.add(_RecentActivity(
        id: 'checkin-${checkin.date.microsecondsSinceEpoch}',
        date: checkin.date,
        title: 'Check-in selesai',
        description: conditionLabel,
        icon: Icons.task_alt_rounded,
        accent: SkinHomePage.deepGreen,
        iconBackground: const Color(0xFFE2F3EC),
      ));
    }

    JourneyPhoto? oldestPhoto;
    for (final photo in store.photos) {
      if (oldestPhoto == null || photo.date.isBefore(oldestPhoto.date)) {
        oldestPhoto = photo;
      }
    }

    for (final photo in store.photos) {
      if (photosInCheckins.contains(photo.id)) continue;
      final isFirstScan = oldestPhoto?.id == photo.id &&
          store.baselineDate != null &&
          SkinJourneyStore.sameDay(photo.date, store.baselineDate!);
      final findings = photo.visualFindings;
      final description = findings.isNotEmpty
          ? '${findings.take(2).join(' & ')}${findings.length > 2 ? ' +${findings.length - 2}' : ''} tercatat dari hasil analisismu.'
          : photo.skinType != null
              ? 'Tipe kulit ${photo.skinType} tercatat di perjalananmu.'
              : 'Hasil analisis kulit tersimpan di perjalananmu.';
      activities.add(_RecentActivity(
        id: photo.id,
        date: photo.date,
        title: isFirstScan ? 'Scan awal tersimpan' : 'Hasil scan tersimpan',
        description: description,
        icon: Icons.center_focus_strong_rounded,
        accent: const Color(0xFFB66446),
        iconBackground: const Color(0xFFFFEBDD),
      ));
    }

    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities.take(3).toList(growable: false);
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('recent-activity-empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE9E2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.history_rounded, color: Color(0xFF7B918B), size: 23),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hasil scan dan check-in terbarumu akan muncul di sini.',
              style: TextStyle(
                color: Color(0xFF667B7D),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final _RecentActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('recent-activity-card'),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE9E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D18372F),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: activity.iconBackground,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(activity.icon, color: activity.accent, size: 20),
              ),
              const Spacer(),
              Text(
                _activityDate(activity.date, SkinJourneyStore.instance.today),
                style: const TextStyle(
                  color: Color(0xFF81918D),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            activity.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SkinHomePage.navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            activity.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF667B7D),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _activityDate(DateTime date, DateTime today) {
    final eventDay = DateTime(date.year, date.month, date.day);
    final currentDay = DateTime(today.year, today.month, today.day);
    final difference = currentDay.difference(eventDay).inDays;
    final time =
        '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';
    if (difference == 0) return 'Hari ini · $time';
    if (difference == 1) return 'Kemarin · $time';
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _RecentActivity {
  const _RecentActivity({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.iconBackground,
  });

  final String id;
  final DateTime date;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final Color iconBackground;
}
