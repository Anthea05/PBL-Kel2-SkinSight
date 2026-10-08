import 'dart:math' as math;

import 'package:flutter/material.dart';

class SkinStartPage extends StatelessWidget {
  const SkinStartPage({super.key});

  static const _deepTeal = Color(0xFF064E48);
  static const _teal = Color(0xFF168F7C);
  static const _muted = Color(0xFF8BA7A2);
  static const _assetBase = 'lib/assets/images';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                '$_assetBase/start_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final compact = width < 350;
                    final contentHeight = math.max(
                      constraints.maxHeight,
                      compact ? 700.0 : 780.0,
                    );

                    return SingleChildScrollView(
                      key: const Key('start-scroll'),
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: width,
                        height: contentHeight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 18 : 20,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: contentHeight * .080),
                              const _Brand(),
                              SizedBox(height: contentHeight * .065),
                              _JourneyTitle(compact: compact),
                              const SizedBox(height: 14),
                              Text(
                                'Jika kamu ingin kulitmu bersinar sepertiku,\n'
                                'kamu harus merawat kulitmu\n'
                                '-anjazz.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: compact ? 15 : 17,
                                  height: 1.38,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: contentHeight * .018),
                              Expanded(
                                child: _JourneyScene(compact: compact),
                              ),
                              SizedBox(height: contentHeight * .018),
                              _StartButton(compact: compact),
                              SizedBox(height: contentHeight * .110),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 38,
          height: 38,
          child: CustomPaint(painter: _SkinMarkPainter()),
        ),
        const SizedBox(width: 10),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'Skin',
                style: TextStyle(color: SkinStartPage._deepTeal),
              ),
              TextSpan(
                text: 'Sight',
                style: TextStyle(color: SkinStartPage._teal),
              ),
            ],
          ),
          style: const TextStyle(
            fontSize: 25,
            letterSpacing: -.8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _JourneyTitle extends StatelessWidget {
  final bool compact;

  const _JourneyTitle({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Start your\n',
                style: TextStyle(color: SkinStartPage._deepTeal),
              ),
              TextSpan(
                text: 'skin journey',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF1BA18E), Color(0xFF087B6B)],
                    ).createShader(const Rect.fromLTWH(0, 0, 280, 50)),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 44 : 50,
            height: .98,
            letterSpacing: -1.8,
            fontWeight: FontWeight.w900,
          ),
        ),
        Positioned(
          right: compact ? 2 : 7,
          bottom: compact ? 8 : 10,
          child: const _AccentBurst(),
        ),
      ],
    );
  }
}

class _JourneyScene extends StatelessWidget {
  final bool compact;

  const _JourneyScene({required this.compact});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sceneWidth = constraints.maxWidth;
        final sceneHeight = constraints.maxHeight;
        final avatarSize = math.min(
          compact ? 230.0 : 285.0,
          math.min(sceneWidth * .82, sceneHeight * .80),
        );
        final tileSize = compact ? 68.0 : 78.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _ConnectorPainter()),
            ),
            Align(
              alignment: const Alignment(0, -.02),
              child: Image.asset(
                '${SkinStartPage._assetBase}/start_avatar.png',
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: sceneWidth * .02,
              top: sceneHeight * .10,
              child: _FloatingTile(
                size: tileSize,
                angle: -.10,
                child: const CustomPaint(painter: _SkinLayerPainter()),
              ),
            ),
            Positioned(
              right: sceneWidth * .02,
              top: sceneHeight * .12,
              child: _FloatingTile(
                size: tileSize,
                angle: .10,
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Color(0xFF67BEEA),
                  size: 39,
                ),
              ),
            ),
            Positioned(
              left: sceneWidth * .03,
              bottom: sceneHeight * .08,
              child: _FloatingTile(
                size: tileSize,
                angle: -.09,
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF7AD5B7),
                  size: 42,
                ),
              ),
            ),
            Positioned(
              right: sceneWidth * .03,
              bottom: sceneHeight * .07,
              child: _FloatingTile(
                size: tileSize,
                angle: .10,
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF79D7B6),
                  size: 46,
                ),
              ),
            ),
            Positioned(
              left: sceneWidth * .23,
              top: sceneHeight * .30,
              child: const _MiniBurst(),
            ),
            Positioned(
              right: sceneWidth * .21,
              bottom: sceneHeight * .28,
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF47C2AC),
                size: 22,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloatingTile extends StatelessWidget {
  final double size;
  final double angle;
  final Widget child;

  const _FloatingTile({
    required this.size,
    required this.angle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * .18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .84),
          borderRadius: BorderRadius.circular(size * .26),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: SkinStartPage._teal.withValues(alpha: .10),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final bool compact;

  const _StartButton({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('start-button'),
        onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
        borderRadius: BorderRadius.circular(34),
        child: Ink(
          height: compact ? 56 : 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF169481), Color(0xFF087B6D)],
            ),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: SkinStartPage._deepTeal.withValues(alpha: .12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mulai',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: compact ? 29 : 33,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkinMarkPainter extends CustomPainter {
  const _SkinMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..color = SkinStartPage._teal;
    final fill = Paint()..color = SkinStartPage._teal;
    canvas.drawCircle(center, size.width * .43, stroke);
    canvas.drawCircle(center, size.width * .105, fill);
    for (var index = 0; index < 8; index++) {
      final angle = (math.pi * 2 / 8) * index;
      final point = Offset(
        center.dx + math.cos(angle) * size.width * .28,
        center.dy + math.sin(angle) * size.width * .28,
      );
      canvas.drawCircle(point, size.width * .04, fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SkinLayerPainter extends CustomPainter {
  const _SkinLayerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, size.height * .18, size.width - 2, size.height * .62),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFFFFD9C5));
    final wave = Path()
      ..moveTo(1, size.height * .45)
      ..cubicTo(
        size.width * .22,
        size.height * .30,
        size.width * .34,
        size.height * .58,
        size.width * .54,
        size.height * .43,
      )
      ..cubicTo(
        size.width * .72,
        size.height * .29,
        size.width * .83,
        size.height * .51,
        size.width - 1,
        size.height * .35,
      )
      ..lineTo(size.width - 1, size.height * .18)
      ..lineTo(1, size.height * .18)
      ..close();
    canvas.drawPath(wave, Paint()..color = const Color(0xFFFFB69F));
    final dot = Paint()..color = const Color(0xFFF4A98E);
    canvas.drawCircle(Offset(size.width * .24, size.height * .62), 2.5, dot);
    canvas.drawCircle(Offset(size.width * .72, size.height * .61), 2.5, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF5FC7AE).withValues(alpha: .36);
    final center = Offset(size.width / 2, size.height * .55);
    canvas.drawLine(Offset(size.width * .16, size.height * .23), center, paint);
    canvas.drawLine(Offset(size.width * .84, size.height * .25), center, paint);
    canvas.drawLine(Offset(size.width * .17, size.height * .78), center, paint);
    canvas.drawLine(Offset(size.width * .83, size.height * .80), center, paint);
    canvas.drawCircle(center, math.min(size.width, size.height) * .30, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AccentBurst extends StatelessWidget {
  const _AccentBurst();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 35,
      height: 48,
      child: Stack(
        children: [
          Positioned(left: 1, top: 2, child: _Ray(angle: .58)),
          Positioned(right: 0, top: 18, child: _Ray(angle: 0)),
          Positioned(left: 4, bottom: 0, child: _Ray(angle: -.55)),
        ],
      ),
    );
  }
}

class _MiniBurst extends StatelessWidget {
  const _MiniBurst();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        children: [
          Positioned(left: 0, top: 5, child: _Ray(angle: .70, length: 21)),
          Positioned(right: 3, top: 0, child: _Ray(angle: .15, length: 22)),
          Positioned(right: 0, bottom: 2, child: _Ray(angle: -.65, length: 20)),
        ],
      ),
    );
  }
}

class _Ray extends StatelessWidget {
  final double angle;
  final double length;

  const _Ray({required this.angle, this.length = 19});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: length,
        height: 7,
        decoration: BoxDecoration(
          color: const Color(0xFFFFC64D),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
