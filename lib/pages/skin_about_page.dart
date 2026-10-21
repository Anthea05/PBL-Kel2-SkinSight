import 'package:flutter/material.dart';

import '../theme/skin_theme.dart';
import '../widgets/skin_bottom_nav.dart';

class SkinAboutPage extends StatelessWidget {
  const SkinAboutPage({super.key, this.embedded = false});

  final bool embedded;

  static const _assetBase = 'lib/assets/images';

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
        child: SingleChildScrollView(
          key: const Key('about-page-scroll'),
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AboutBrandBar(showBack: !embedded),
              const SizedBox(height: 18),
              const _AboutHero(),
              const SizedBox(height: 28),
              const Text(
                'TENTANG KAMI',
                key: Key('about-page-title'),
                style: TextStyle(
                  color: SkinTokens.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Lebih dekat dengan kulitmu.',
                style: TextStyle(
                  color: SkinTokens.ink,
                  fontSize: 30,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'SkinSight hadir untuk membantu kamu memahami perubahan kulit secara lebih tenang—melalui catatan visual, edukasi yang mudah dibaca, dan check-in yang konsisten.',
                style: TextStyle(
                  color: SkinTokens.muted,
                  fontSize: 15,
                  height: 1.58,
                ),
              ),
              const SizedBox(height: 34),
              const _PurposeSection(),
              const SizedBox(height: 30),
              const _Principles(),
              const SizedBox(height: 30),
              const _MedicalNote(),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'SkinSight · Versi 1.1.0',
                  style: TextStyle(
                    color: SkinTokens.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (embedded) {
      return ColoredBox(color: const Color(0xFFFFFBF3), child: content);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF3),
      body: SafeArea(bottom: false, child: content),
      bottomNavigationBar: const SkinBottomNav(currentIndex: -1),
    );
  }
}

class _AboutBrandBar extends StatelessWidget {
  final bool showBack;
  const _AboutBrandBar({required this.showBack});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          if (showBack) ...[
            Material(
              color: Colors.white.withValues(alpha: .94),
              shape: const CircleBorder(),
              child: InkWell(
                key: const Key('about-back'),
                onTap: () => Navigator.of(context).maybePop(),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: SkinTokens.primary,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          const _BrandIcon(),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'SkinSight',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: SkinTokens.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -.4,
              ),
            ),
          ),
          if (constraints.maxWidth >= 350) ...[
            const SizedBox(width: 12),
            const Text(
              'Cerita kami',
              style: TextStyle(
                color: SkinTokens.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: SkinTokens.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.face_retouching_natural_rounded,
        color: Colors.white,
        size: 21,
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final height = compact ? 205.0 : 238.0;
        return Container(
          key: const Key('about-hero'),
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD8F0EB), Color(0xFFB8E2E5)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -34,
                top: -42,
                child: Container(
                  width: 145,
                  height: 145,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .48),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -18,
                bottom: -54,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7D2).withValues(alpha: .82),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: compact ? -14 : 8,
                bottom: -2,
                width: compact ? 185 : 215,
                height: compact ? 185 : 220,
                child: Image.asset(
                  '${SkinAboutPage._assetBase}/skin_girl.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
              Positioned(
                left: 21,
                top: 25,
                width: compact ? 135 : 165,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kenali. Catat.\nRawat dengan sadar.',
                      style: TextStyle(
                        color: SkinTokens.ink,
                        fontSize: 21,
                        height: 1.16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.4,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 34,
                      child: Divider(
                        thickness: 3,
                        color: SkinTokens.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                bottom: 19,
                child: Container(
                  width: compact ? 50 : 58,
                  height: compact ? 50 : 58,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .9),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    '${SkinAboutPage._assetBase}/cat_happy.png',
                    fit: BoxFit.contain,
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

class _PurposeSection extends StatelessWidget {
  const _PurposeSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Divider(thickness: 3, color: Color(0xFFFF9B79)),
        ),
        SizedBox(height: 10),
        Text(
          'Tujuan kami',
          style: TextStyle(
            color: SkinTokens.ink,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Membuat pemantauan kulit terasa sederhana, relevan, dan tidak mengintimidasi. Bukan sekadar sekali scan, tetapi kebiasaan kecil untuk mengenali pola dari waktu ke waktu.',
          style: TextStyle(
            color: SkinTokens.muted,
            fontSize: 14.5,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _Principles extends StatelessWidget {
  const _Principles();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Principle(
          icon: Icons.visibility_outlined,
          title: 'Jelas, bukan menakutkan',
          body: 'Informasi disampaikan dengan bahasa yang mudah dipahami.',
        ),
        Divider(height: 26),
        _Principle(
          icon: Icons.timeline_rounded,
          title: 'Konsisten dari waktu ke waktu',
          body: 'Scan dan check-in disusun menjadi perjalanan yang utuh.',
        ),
        Divider(height: 26),
        _Principle(
          icon: Icons.health_and_safety_outlined,
          title: 'Aman dalam batasnya',
          body: 'Observasi awal tetap dibedakan dari diagnosis medis.',
        ),
      ],
    );
  }
}

class _Principle extends StatelessWidget {
  const _Principle({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: SkinTokens.mint,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: SkinTokens.primary, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: SkinTokens.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  color: SkinTokens.muted,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MedicalNote extends StatelessWidget {
  const _MedicalNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: SkinTokens.primary, size: 22),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'SkinSight bukan alat diagnosis, resep, atau pengganti konsultasi dengan dokter kulit.',
              style: TextStyle(
                color: SkinTokens.ink,
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
