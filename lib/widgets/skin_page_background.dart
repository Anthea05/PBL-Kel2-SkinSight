import 'package:flutter/material.dart';

/// Background visual bersama untuk halaman SkinSight yang sebelumnya polos.
/// Dekorasi tidak menerima input sehingga tidak mengganggu gesture halaman.
class SkinPageBackground extends StatelessWidget {
  const SkinPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9FBF7), Color(0xFFEAF5F1)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -88,
            right: -72,
            child: IgnorePointer(
                child: _BackgroundOrb(
              size: 220,
              color: Color(0x3074C3B4),
            )),
          ),
          Positioned(
            left: -105,
            bottom: 56,
            child: IgnorePointer(
                child: _BackgroundOrb(
              size: 235,
              color: Color(0x20F0B3A7),
            )),
          ),
          child,
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
