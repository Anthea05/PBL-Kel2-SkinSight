import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_data.dart';
import 'skin_help_page.dart';
import 'skin_quiz_page.dart';

class SkinHomePage extends StatelessWidget {
  const SkinHomePage({super.key});

  static const String assetBase = 'lib/assets/images';
  static const Color green = Color(0xFF168A78);
  static const Color deepGreen = Color(0xFF087467);
  static const Color cream = Color(0xFFFFF8EB);
  static const Color navy = Color(0xFF182A35);
  static const Color coral = Color(0xFFFF6B70);
  static const Color orange = Color(0xFFFFB43B);
  static const Color sky = Color(0xFF35A9EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const SizedBox.expand(child: _ResponsiveHome()),
          ),
        ),
      ),
    );
  }
}

class _ResponsiveHome extends StatelessWidget {
  const _ResponsiveHome();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [SkinHomePage.cream, Color(0xFFF8F9EE)],
          ),
        ),
        child: Column(
          children: [
            const Expanded(child: _HomeScrollView()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _BottomNav(
                compact: MediaQuery.sizeOf(context).width < 350,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScrollView extends StatelessWidget {
  const _HomeScrollView();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;
        final horizontal = compact ? 14.0 : 20.0;
        final heroHeight = 430 * constraints.maxWidth / 390;
        final lowerMinHeight = (constraints.maxHeight - heroHeight + 22).clamp(
          0.0,
          double.infinity,
        );

        return CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _Hero()),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -22),
                child: Container(
                  constraints: BoxConstraints(minHeight: lowerMinHeight),
                  padding: EdgeInsets.fromLTRB(horizontal, 28, horizontal, 0),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        SkinHomePage.cream,
                        Color(0xFFFFFAF0),
                        Color(0xFFF4F8EC),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(220, 34),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned.fill(
                        child: IgnorePointer(child: _LowerDecorations()),
                      ),
                      Column(
                        children: [
                          _ActivityHeader(compact: compact),
                          const SizedBox(height: 16),
                          _ScanCard(compact: compact),
                          const SizedBox(height: 16),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              key: const Key('open-history'),
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/history'),
                              borderRadius: BorderRadius.circular(
                                compact ? 24 : 28,
                              ),
                              child: _HistoryCard(compact: compact),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final scale = width / 390;
        final fontScale = scale.clamp(.90, 1.18);

        return SizedBox(
          height: 430 * scale,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
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
                      stops: [0, .67, 1],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(child: _HeroDecorations()),
              const Positioned(
                left: 0,
                right: 0,
                bottom: -1,
                height: 54,
                child: _SkinLayerTransition(),
              ),
              Positioned(
                left: 20 * scale,
                right: 20 * scale,
                top: 18 * scale,
                child: _Header(scale: fontScale),
              ),
              Positioned(
                left: 18 * scale,
                top: 108 * scale,
                width: 166 * scale,
                child: Image.asset(
                  '${SkinHomePage.assetBase}/skin_analyze_title.png',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: 8 * scale,
                top: 66 * scale,
                width: 187 * scale,
                height: 250 * scale,
                child: Image.asset(
                  '${SkinHomePage.assetBase}/skin_girl.png',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: -3 * scale,
                top: 188 * scale,
                width: 190 * scale,
                height: 143 * scale,
                child: Image.asset(
                  '${SkinHomePage.assetBase}/skin_magnifier.png',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: 17 * scale,
                top: 235 * scale,
                width: 188 * scale,
                child: _DescriptionCard(scale: fontScale),
              ),
              Positioned(
                left: 16 * scale,
                top: 318 * scale,
                width: 218 * scale,
                child: _TryNow(scale: scale),
              ),
            ],
          ),
        );
      },
    );
  }
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

class _LowerDecorations extends StatelessWidget {
  const _LowerDecorations();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              left: -22,
              top: 110,
              width: 62,
              height: 62,
              child: Opacity(opacity: .14, child: const _Bubble()),
            ),
            Positioned(
              right: -14,
              top: 285,
              width: 72,
              height: 56,
              child: Opacity(opacity: .14, child: const _MoleculeCluster()),
            ),
            Positioned(
              left: -8,
              bottom: 100,
              width: 78,
              height: 66,
              child: Opacity(opacity: .13, child: const _SkinLayerMotif()),
            ),
            Positioned(
              right: 18,
              bottom: 38,
              width: 20,
              height: 20,
              child: Opacity(
                opacity: .22,
                child: const _DropletAccent(color: SkinHomePage.sky),
              ),
            ),
          ],
        );
      },
    );
  }
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
                            ? Text(
                                _profileInitials(profile.name),
                                style: TextStyle(
                                  color: SkinHomePage.deepGreen,
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            : Image.memory(
                                profile.photoBytes!,
                                width: avatarSize,
                                height: avatarSize,
                                fit: BoxFit.cover,
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 25 * scale,
                color: SkinHomePage.deepGreen,
              ),
            ),
            Positioned(
              top: 4,
              right: 5,
              child: Container(
                width: 9 * scale,
                height: 9 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5C63),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
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
  final double scale;

  const _TryNow({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('open-quiz-try'),
        onTap: () => _openQuiz(context),
        borderRadius: BorderRadius.circular(40 * scale),
        child: Container(
          height: 68 * scale,
          padding: EdgeInsets.fromLTRB(
            22 * scale,
            6 * scale,
            7 * scale,
            6 * scale,
          ),
          decoration: BoxDecoration(
            color: SkinHomePage.green,
            borderRadius: BorderRadius.circular(40 * scale),
            border: Border.all(color: Colors.white, width: 5 * scale),
            boxShadow: [
              BoxShadow(
                color: SkinHomePage.deepGreen.withValues(alpha: .20),
                blurRadius: 13 * scale,
                offset: Offset(0, 6 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Try Now',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (22 * scale).clamp(18, 26),
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(color: Color(0x33000000), offset: Offset(0, 2)),
                    ],
                  ),
                ),
              ),
              Container(
                width: 48 * scale,
                height: 48 * scale,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: SkinHomePage.deepGreen,
                  size: 28 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final double scale;

  const _DescriptionCard({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -.035,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 13 * scale,
          vertical: 10 * scale,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEFC6),
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: Colors.white, width: 3 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9A6A35).withValues(alpha: .12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Kulit yang sehat adalah\ncerminan dari kesehatan secara keseluruhan.\n— Dr. Murad',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5 * scale,
            height: 1.25,
            color: const Color(0xFF533B2B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  final bool compact;

  const _ActivityHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Aktivitas Kulit',
            maxLines: 1,
            style: TextStyle(
              fontSize: compact ? 21 : 24,
              fontWeight: FontWeight.w900,
              color: SkinHomePage.navy,
            ),
          ),
        ),
        Text(
          'Lihat Semua',
          style: TextStyle(
            fontSize: compact ? 11 : 13,
            color: SkinHomePage.deepGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.chevron_right_rounded,
          color: SkinHomePage.deepGreen,
          size: 22,
        ),
      ],
    );
  }
}

class _ScanCard extends StatelessWidget {
  final bool compact;

  const _ScanCard({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 16,
        compact ? 14 : 18,
        compact ? 12 : 16,
        compact ? 14 : 18,
      ),
      decoration: _card(compact ? 24 : 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 48 : 54,
                height: compact ? 48 : 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F4F0),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: SkinHomePage.deepGreen.withValues(alpha: .12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.center_focus_strong_rounded,
                  color: SkinHomePage.deepGreen,
                  size: compact ? 26 : 29,
                ),
              ),
              SizedBox(width: compact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Terakhir',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 15 : 17,
                        fontWeight: FontWeight.w900,
                        color: SkinHomePage.navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Kemarin, 20:15',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: compact ? 10 : 12,
                        color: const Color(0xFF829194),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '82',
                          style: TextStyle(
                            fontSize: compact ? 28 : 32,
                            height: .9,
                            color: SkinHomePage.deepGreen,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: '/100',
                          style: TextStyle(
                            fontSize: compact ? 11 : 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  _HealthBadge(compact: compact),
                ],
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 18),
          const Divider(height: 1, color: Color(0xFFE4E8E7)),
          SizedBox(height: compact ? 13 : 16),
          const Row(
            children: [
              Expanded(
                child: _Metric(
                  'Kemerahan',
                  34,
                  Color(0xFFFF6470),
                  Icons.blur_on_rounded,
                ),
              ),
              _Rule(),
              Expanded(
                child: _Metric(
                  'Minyak',
                  68,
                  Color(0xFFFFB131),
                  Icons.water_drop_outlined,
                ),
              ),
              _Rule(),
              Expanded(
                child: _Metric(
                  'Hidrasi',
                  78,
                  Color(0xFF2DA6F2),
                  Icons.water_drop_outlined,
                ),
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

  const _HealthBadge({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: .018,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFDDF6E7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: SkinHomePage.deepGreen.withValues(alpha: .10),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: compact ? 9 : 10,
              color: SkinHomePage.orange,
            ),
            const SizedBox(width: 3),
            Text(
              'Kondisi Kulit Baik',
              style: TextStyle(
                fontSize: compact ? 8 : 9,
                color: SkinHomePage.deepGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _Metric(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: value.isEven ? -.045 : .045,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .17),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: .16),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ),
                    Text(
                      '$value%',
                      style: const TextStyle(
                        fontSize: 19,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: SkinHomePage.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: value / 100,
              backgroundColor: color.withValues(alpha: .16),
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
    return Container(width: 1, height: 48, color: const Color(0xFFE0E7E5));
  }
}

class _HistoryCard extends StatelessWidget {
  final bool compact;

  const _HistoryCard({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 186 : 202,
      padding: EdgeInsets.fromLTRB(compact ? 14 : 18, 16, 12, 0),
      decoration: _card(compact ? 24 : 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final catWidth = compact ? 126.0 : 148.0;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: constraints.maxWidth * .63,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: compact ? 34 : 38,
                      height: compact ? 34 : 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4F4F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color:
                                SkinHomePage.deepGreen.withValues(alpha: .12),
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        size: compact ? 21 : 23,
                        color: SkinHomePage.deepGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Riwayat Perubahan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 14 : 16,
                              fontWeight: FontWeight.w900,
                              color: SkinHomePage.navy,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '7 scan bulan ini  ',
                                  style: TextStyle(
                                    fontSize: compact ? 10 : 11,
                                    color: const Color(0xFF819093),
                                  ),
                                ),
                                TextSpan(
                                  text: '+6 poin',
                                  style: TextStyle(
                                    fontSize: compact ? 10 : 11,
                                    color: SkinHomePage.deepGreen,
                                    fontWeight: FontWeight.w900,
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
              Positioned(
                left: 8,
                bottom: 0,
                child: _Bars(compact: compact),
              ),
              Positioned(
                right: 0,
                bottom: -10,
                width: catWidth,
                height: catWidth,
                child: Image.asset(
                  '${SkinHomePage.assetBase}/cat_happy.png',
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: compact ? 16 : 22,
                top: compact ? 43 : 48,
                child: _HistoryBadge(compact: compact),
              ),
              Positioned(
                right: compact ? 102 : 122,
                bottom: compact ? 18 : 22,
                width: compact ? 18 : 22,
                height: compact ? 18 : 22,
                child: Opacity(opacity: .36, child: const _Bubble()),
              ),
              Positioned(
                right: compact ? 88 : 105,
                bottom: compact ? 45 : 52,
                width: compact ? 14 : 17,
                height: compact ? 14 : 17,
                child: const _DropletAccent(color: Color(0x6635A9EE)),
              ),
              const Positioned(
                right: 0,
                top: 5,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6D7C86),
                  size: 26,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryBadge extends StatelessWidget {
  final bool compact;

  const _HistoryBadge({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -.035,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 6 : 7,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF55C69E), SkinHomePage.green],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: SkinHomePage.deepGreen.withValues(alpha: .15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: const Color(0xFFFFD05A),
              size: compact ? 11 : 13,
            ),
            const SizedBox(width: 4),
            Text(
              'KULITMU\nMAKIN SEHAT!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 9 : 10,
                height: 1.04,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  final bool compact;

  const _Bars({required this.compact});

  @override
  Widget build(BuildContext context) {
    const values = [35.0, 47.0, 59.0, 50.0, 57.0, 68.0, 82.0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (i) {
        return Container(
          width: compact ? 10 : 12,
          height: values[i] * (compact ? .86 : 1),
          margin: EdgeInsets.only(right: compact ? 5 : 7),
          decoration: BoxDecoration(
            color: SkinHomePage.green.withValues(alpha: .18 + i * .09),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        );
      }),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final bool compact;

  const _BottomNav({required this.compact});

  @override
  Widget build(BuildContext context) {
    final centerSize = compact ? 68.0 : 76.0;

    return SizedBox(
      height: compact ? 72 : 78,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 34),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .98),
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: SkinHomePage.deepGreen.withValues(alpha: .11),
              blurRadius: 24,
              offset: const Offset(0, 8),
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
                const _NavItem(Icons.home_rounded, 'Home', true),
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
              top: compact ? -18 : -22,
              child: Semantics(
                button: true,
                label: 'Buka kuis kondisi kulit',
                child: GestureDetector(
                  key: const Key('open-quiz-scan'),
                  onTap: () => _openQuiz(context),
                  child: Container(
                    width: centerSize,
                    height: centerSize,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: SkinHomePage.green.withValues(alpha: .22),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: SkinHomePage.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.center_focus_strong_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem(
    this.icon,
    this.label,
    this.selected, {
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? SkinHomePage.deepGreen : const Color(0xFF78878A);

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 70,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 3),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: SkinHomePage.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
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

BoxDecoration _card(double radius) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: SkinHomePage.deepGreen.withValues(alpha: .10),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(
        color: SkinHomePage.deepGreen.withValues(alpha: .09),
        blurRadius: 22,
        offset: const Offset(0, 9),
      ),
      BoxShadow(
        color: SkinHomePage.coral.withValues(alpha: .035),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
