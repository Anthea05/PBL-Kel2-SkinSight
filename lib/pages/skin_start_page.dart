import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/skin_theme.dart';

class SkinStartPage extends StatelessWidget {
  const SkinStartPage({super.key});

  static const _deepTeal = SkinTokens.primaryDark;
  static const _teal = SkinTokens.primary;
  static const _muted = SkinTokens.muted;
  static const _assetBase = 'lib/assets/images';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkinTokens.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                '$_assetBase/start_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              ColoredBox(color: Colors.white.withValues(alpha: .45)),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final compact = width < 350;
                    final contentHeight = math.max(
                      constraints.maxHeight,
                      compact ? 600.0 : 680.0,
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
                                'Kenali kondisi kulitmu, catat perubahan,\n'
                                'dan pahami perawatan dasarnya.',
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
                              SizedBox(height: contentHeight * .055),
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
            fontWeight: FontWeight.w700,
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
  Widget build(BuildContext context) => Text('Start your\nskin journey',
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: compact ? 38 : 44,
          height: 1.08,
          letterSpacing: -1.2,
          fontWeight: FontWeight.w700,
          color: SkinTokens.primaryDark));
}

class _JourneyScene extends StatelessWidget {
  final bool compact;
  const _JourneyScene({required this.compact});
  @override
  Widget build(BuildContext context) => Center(
      child: Image.asset('${SkinStartPage._assetBase}/start_avatar.png',
          width: compact ? 220 : 260, fit: BoxFit.contain));
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
        borderRadius: BorderRadius.circular(SkinTokens.radius),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: SkinTokens.primary,
            borderRadius: BorderRadius.circular(SkinTokens.radius),
            boxShadow: SkinTokens.shadows,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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
