import 'package:flutter/material.dart';

import '../theme/skin_theme.dart';
import '../widgets/skin_bottom_nav.dart';
import '../widgets/skin_page_background.dart';

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
              const SizedBox(height: 14),
              const _AboutLegalNav(),
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
                'Membantu mencatat, bukan mendiagnosis.',
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
                'SkinSight adalah aplikasi pemantauan mandiri yang menggabungkan foto, jawaban kuis, check-in, dan materi edukasi. Informasi yang ditampilkan membantu pengguna meninjau catatan dari waktu ke waktu, bukan memastikan kondisi medis.',
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
                  'SkinSight · Prototipe versi 1.1.0',
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
      return SkinPageBackground(child: content);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF3),
      body: SkinPageBackground(
        child: SafeArea(bottom: false, child: content),
      ),
      bottomNavigationBar: const SkinBottomNav(currentIndex: -1),
    );
  }
}

class _AboutLegalNav extends StatelessWidget {
  const _AboutLegalNav();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const _AboutBubble(
          label: 'Profil Kami',
          selected: true,
        ),
        _AboutBubble(
          key: const Key('about-open-privacy'),
          label: 'Kebijakan Privasi',
          onTap: () => Navigator.of(context).pushNamed('/privacy'),
        ),
        _AboutBubble(
          key: const Key('about-open-terms'),
          label: 'Syarat & Ketentuan',
          onTap: () => Navigator.of(context).pushNamed('/terms'),
        ),
      ],
    );
  }
}

class _AboutBubble extends StatelessWidget {
  const _AboutBubble({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? SkinTokens.primary : Colors.white.withValues(alpha: .7),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? SkinTokens.primary : SkinTokens.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : SkinTokens.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
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
              'Tentang produk',
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
                      'Amati. Catat.\nPahami perubahannya.',
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
          'Tujuan pengembangan',
          style: TextStyle(
            color: SkinTokens.ink,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Menyediakan satu tempat untuk menyimpan catatan kondisi kulit secara berkala. Foto dan check-in dapat membantu pengguna membandingkan catatannya sendiri, tetapi hasilnya tetap dipengaruhi pencahayaan, posisi kamera, dan kualitas gambar.',
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
          icon: Icons.fact_check_outlined,
          title: 'Berdasarkan data yang diberikan',
          body:
              'Ringkasan dibuat dari foto dan jawaban yang dimasukkan pengguna, sehingga hasil dapat berbeda ketika kondisi pengambilan data berubah.',
        ),
        Divider(height: 26),
        _Principle(
          icon: Icons.timeline_rounded,
          title: 'Berfokus pada pencatatan berkala',
          body:
              'Journey mengelompokkan baseline, foto, kuis, dan check-in agar setiap perjalanan dapat ditinjau secara terpisah.',
        ),
        Divider(height: 26),
        _Principle(
          icon: Icons.menu_book_outlined,
          title: 'Edukasi dengan rujukan',
          body:
              'Materi edukasi menyertakan sumber yang dapat diperiksa dan disajikan sebagai informasi umum, bukan rekomendasi terapi pribadi.',
        ),
        Divider(height: 26),
        _Principle(
          icon: Icons.health_and_safety_outlined,
          title: 'Batas penggunaan yang jelas',
          body:
              'Hasil visual merupakan observasi awal dan tidak digunakan untuk menetapkan diagnosis atau menggantikan pemeriksaan tenaga kesehatan.',
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
              'Fitur analisis SkinSight masih berupa prototipe dan belum divalidasi sebagai alat medis. Keluhan yang menetap, memburuk, nyeri, atau mengkhawatirkan perlu diperiksa oleh tenaga kesehatan.',
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
