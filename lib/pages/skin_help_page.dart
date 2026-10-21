import 'package:flutter/material.dart';

import '../theme/skin_theme.dart';
import 'package:flutter/services.dart';

import '../widgets/skin_bottom_nav.dart';

class SkinHelpPage extends StatelessWidget {
  final bool embedded;

  const SkinHelpPage({super.key, this.embedded = false});

  static const _teal = SkinTokens.primary;
  static const _deepTeal = SkinTokens.primaryDark;
  static const _navy = SkinTokens.ink;
  static const _coral = SkinTokens.coral;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: SkinTokens.background),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 350;
              return Column(
                children: [
                  if (embedded)
                    _EmbeddedHelpHeader(compact: compact)
                  else
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
                ],
              );
            },
          ),
        ),
      ),
    );

    if (embedded) return content;

    return Scaffold(
      backgroundColor: SkinTokens.background,
      body: SafeArea(bottom: false, child: content),
      bottomNavigationBar: const SkinBottomNav(currentIndex: -1),
    );
  }
}

class _EmbeddedHelpHeader extends StatelessWidget {
  final bool compact;

  const _EmbeddedHelpHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 18 : 22, 18, 18, 8),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Pusat Bantuan',
          style: TextStyle(
            color: SkinHelpPage._navy,
            fontSize: 27,
            fontWeight: FontWeight.w700,
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
                fontWeight: FontWeight.w700,
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
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(4, 4, 4, 20),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                'Panduan penggunaan, privasi, dan jawaban untuk pertanyaanmu.',
                style: SkinTokens.body)),
      );
}

class _HelpTopicsPanel extends StatelessWidget {
  const _HelpTopicsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SkinTokens.radius),
        boxShadow: SkinTokens.shadows,
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkinTokens.radius),
          side: BorderSide.none,
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
              color: SkinTokens.blue,
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
              color: SkinTokens.primary,
              title: 'Kebijakan privasi',
              subtitle: 'Cara kami memperlakukan foto dan datamu.',
              child: _PrivacyContent(),
            ),
            _TopicDivider(),
            _HelpTopic(
              key: Key('help-about'),
              icon: Icons.info_outline_rounded,
              color: SkinTokens.amber,
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
      indent: 52,
      endIndent: 16,
      color: SkinTokens.border,
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
        tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(17, 0, 17, 18),
        leading: Icon(icon, color: SkinTokens.primary, size: 23),
        title: Text(
          title,
          style: const TextStyle(
            color: SkinHelpPage._navy,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: SkinTokens.muted,
              fontSize: 14,
            ),
          ),
        ),
        iconColor: SkinHelpPage._deepTeal,
        collapsedIconColor: SkinTokens.muted,
        children: [
          const Divider(color: SkinTokens.border),
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
            'Posisikan wajah di dalam frame dengan cahaya yang cukup.'),
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
                fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: SkinTokens.muted,
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
          'Bisa. Kembali ke Home lalu pilih Scan Instan atau Scan Pemantauan.',
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
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              color: SkinTokens.muted,
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
        borderRadius: BorderRadius.circular(SkinTokens.radius),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(email, style: TextStyle(color: SkinTokens.muted)),
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
      style: TextStyle(color: SkinTokens.muted, height: 1.45),
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
          style: TextStyle(color: SkinTokens.muted, height: 1.45),
        ),
        SizedBox(height: 10),
        Text(
          'Versi 1.1.0',
          style: TextStyle(
            color: SkinHelpPage._deepTeal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
