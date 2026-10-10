import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'skin_quiz_page.dart';

class SkinHelpPage extends StatelessWidget {
  const SkinHelpPage({super.key});

  static const _teal = Color(0xFF168A78);
  static const _deepTeal = Color(0xFF087467);
  static const _navy = Color(0xFF13263A);
  static const _cream = Color(0xFFFFF8EB);
  static const _sky = Color(0xFF2FC1ED);
  static const _coral = Color(0xFFFF6B70);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sky,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2FC1ED), Color(0xFFE9F8F3), _cream],
                  stops: [0, .30, 1],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 350;
                  return Column(
                    children: [
                      _HelpHeader(compact: compact),
                      Expanded(
                        child: SingleChildScrollView(
                          key: const Key('help-scroll'),
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            compact ? 12 : 18,
                            4,
                            compact ? 12 : 18,
                            26,
                          ),
                          child: Column(
                            children: [
                              _WelcomeCard(compact: compact),
                              const SizedBox(height: 8),
                              const _HelpTopicsPanel(),
                            ],
                          ),
                        ),
                      ),
                      _HelpBottomNav(compact: compact),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpHeader extends StatelessWidget {
  final bool compact;

  const _HelpHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 18, 16, compact ? 14 : 18, 8),
      child: Row(
        children: [
          Material(
            color: Colors.white.withValues(alpha: .94),
            shape: const CircleBorder(),
            child: InkWell(
              key: const Key('help-back'),
              onTap: () => Navigator.of(context).pop(),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: compact ? 46 : 52,
                height: compact ? 46 : 52,
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: SkinHelpPage._deepTeal,
                  size: 34,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Pusat Bantuan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SkinHelpPage._navy,
                fontSize: compact ? 23 : 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: compact ? 46 : 52),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final bool compact;

  const _WelcomeCard({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 6 : 10,
        compact ? 8 : 12,
        compact ? 6 : 10,
        6,
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 56 : 64,
            height: compact ? 56 : 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .82),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: SkinHelpPage._teal,
              size: 34,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ada yang bisa kami bantu?',
                  style: TextStyle(
                    color: SkinHelpPage._navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Pilih topik di bawah untuk menemukan informasi yang kamu butuhkan.',
                  style: TextStyle(
                    color: SkinHelpPage._navy.withValues(alpha: .66),
                    fontSize: compact ? 12 : 13,
                    height: 1.35,
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

class _HelpTopicsPanel extends StatelessWidget {
  const _HelpTopicsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: SkinHelpPage._deepTeal.withValues(alpha: .09),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Material(
        color: Colors.white.withValues(alpha: .96),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(
            color: SkinHelpPage._deepTeal.withValues(alpha: .08),
          ),
        ),
        child: const Column(
          children: [
            _HelpTopic(
              key: Key('help-how-to'),
              icon: Icons.auto_awesome_rounded,
              color: SkinHelpPage._teal,
              title: 'Cara menggunakan SkinSight',
              subtitle: 'Panduan scan kulit dari awal sampai hasil.',
              child: _HowToContent(),
            ),
            _TopicDivider(),
            _HelpTopic(
              key: Key('help-faq'),
              icon: Icons.question_answer_outlined,
              color: Color(0xFF36A7E8),
              title: 'FAQ',
              subtitle: 'Jawaban untuk pertanyaan yang sering muncul.',
              child: _FaqContent(),
            ),
            _TopicDivider(),
            _HelpTopic(
              key: Key('help-contact'),
              icon: Icons.support_agent_rounded,
              color: SkinHelpPage._coral,
              title: 'Hubungi kami',
              subtitle: 'Butuh bantuan lebih lanjut? Tim kami siap.',
              child: _ContactContent(),
            ),
            _TopicDivider(),
            _HelpTopic(
              key: Key('help-privacy'),
              icon: Icons.privacy_tip_outlined,
              color: Color(0xFF9B75D6),
              title: 'Kebijakan privasi',
              subtitle: 'Cara kami memperlakukan foto dan datamu.',
              child: _PrivacyContent(),
            ),
            _TopicDivider(),
            _HelpTopic(
              key: Key('help-about'),
              icon: Icons.info_outline_rounded,
              color: Color(0xFFFFA629),
              title: 'Tentang SkinSight',
              subtitle: 'Kenali tujuan dan batasan aplikasi.',
              child: _AboutContent(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicDivider extends StatelessWidget {
  const _TopicDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 76,
      endIndent: 16,
      color: Color(0xFFE8ECEC),
    );
  }
}

class _HelpTopic extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget child;

  const _HelpTopic({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(17, 0, 17, 18),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 25),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: SkinHelpPage._navy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF718392),
              fontSize: 12,
            ),
          ),
        ),
        iconColor: SkinHelpPage._deepTeal,
        collapsedIconColor: const Color(0xFF718392),
        children: [
          const Divider(color: Color(0xFFE8ECEC)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _HowToContent extends StatelessWidget {
  const _HowToContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _StepRow(1, 'Isi kuis kondisi kulit',
            'Jawab lima pertanyaan singkat sesuai kondisi wajahmu.'),
        _StepRow(2, 'Ambil selfie',
            'Hadap cahaya, lepas kacamata, dan posisikan wajah di dalam frame.'),
        _StepRow(3, 'Lihat hasil',
            'Baca ringkasan kondisi kulit dan panduan perawatanmu.'),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String title;
  final String body;

  const _StepRow(this.number, this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 31,
            height: 31,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: SkinHelpPage._teal,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SkinHelpPage._navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF6C7F8D),
                    height: 1.35,
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

class _FaqContent extends StatelessWidget {
  const _FaqContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FaqItem(
          'Apakah hasil SkinSight merupakan diagnosis medis?',
          'Tidak. Hasil bersifat skrining awal dan edukasi, bukan pengganti pemeriksaan dokter kulit.',
        ),
        _FaqItem(
          'Bagaimana agar hasil foto lebih baik?',
          'Gunakan cahaya dari depan, bersihkan lensa, dan hindari filter atau riasan tebal.',
        ),
        _FaqItem(
          'Apakah saya bisa mengulang scan?',
          'Bisa. Kembali ke Home lalu tekan tombol scan di bagian tengah navigasi.',
        ),
        _FaqItem(
          'Apakah foto wajah saya disimpan?',
          'Foto disimpan di perangkat dan dipakai untuk menyusun rekomendasi. Anda dapat menghapusnya kapan saja lewat menu Riwayat.',
        ),
        _FaqItem(
          'Bagaimana cara membaca hasil?',
          'Hasil berisi tipe kulit, rutinitas pagi dan malam bernomor, zat aktif yang cocok dan yang dihindari, serta disclaimer. Hasil ini panduan umum, bukan diagnosis.',
        ),
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem(this.question, this.answer);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: SkinHelpPage._navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              color: Color(0xFF6C7F8D),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactContent extends StatelessWidget {
  const _ContactContent();

  @override
  Widget build(BuildContext context) {
    const email = 'support@skinsight.app';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email dukungan',
                  style: TextStyle(
                    color: SkinHelpPage._navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(email, style: TextStyle(color: Color(0xFF6C7F8D))),
              ],
            ),
          ),
          IconButton.filledTonal(
            key: const Key('copy-support-email'),
            tooltip: 'Salin email',
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: email));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Email dukungan berhasil disalin.')),
              );
            },
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Foto digunakan untuk menampilkan hasil analisis pada perangkatmu. Hasil hanya disimpan ketika kamu memilih tombol Simpan. Jangan membagikan hasil yang memuat informasi pribadi kepada pihak yang tidak dipercaya.',
      style: TextStyle(color: Color(0xFF6C7F8D), height: 1.45),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SkinSight membantu pengguna mengenali kondisi kulit melalui kuis dan foto wajah dengan pengalaman yang ringan dan mudah dipahami.',
          style: TextStyle(color: Color(0xFF6C7F8D), height: 1.45),
        ),
        SizedBox(height: 10),
        Text(
          'Versi 1.1.0',
          style: TextStyle(
            color: SkinHelpPage._deepTeal,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _HelpBottomNav extends StatelessWidget {
  final bool compact;

  const _HelpBottomNav({required this.compact});

  @override
  Widget build(BuildContext context) {
    final centerSize = compact ? 68.0 : 76.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: SizedBox(
        height: compact ? 72 : 78,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 34),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .98),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: SkinHelpPage._deepTeal.withValues(alpha: .12),
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
                  _HelpNavItem(
                    icon: Icons.home_outlined,
                    label: 'Beranda',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const _HelpNavItem(
                    icon: Icons.help_rounded,
                    label: 'Bantuan',
                    selected: true,
                  ),
                ],
              ),
              Positioned(
                top: compact ? -18 : -22,
                child: GestureDetector(
                  key: const Key('help-open-quiz'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SkinQuizPage(),
                    ),
                  ),
                  child: Container(
                    width: centerSize,
                    height: centerSize,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: SkinHelpPage._teal.withValues(alpha: .22),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: SkinHelpPage._teal,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _HelpNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? SkinHelpPage._deepTeal : const Color(0xFF78878A);
    return GestureDetector(
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
                  color: SkinHelpPage._teal,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
