import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/skin_theme.dart';
import '../widgets/skin_bottom_nav.dart';
import '../widgets/skin_page_background.dart';

class SkinHelpPage extends StatelessWidget {
  final bool embedded;

  const SkinHelpPage({super.key, this.embedded = false});

  static const _teal = SkinTokens.primary;
  static const _deepTeal = SkinTokens.primaryDark;
  static const _navy = SkinTokens.ink;
  static const _coral = SkinTokens.coral;

  @override
  Widget build(BuildContext context) {
    final content = SkinPageBackground(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
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
                        32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _WelcomeCard(compact: compact),
                          const SizedBox(height: 18),
                          const _HelpTopicsPanel(),
                          const SizedBox(height: 20),
                          const _DisclaimerNote(),
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
      bottomNavigationBar: const SkinBottomNav(currentIndex: 2),
    );
  }
}

// ───────────────────────── Header ─────────────────────────

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
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
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
    final size = compact ? 44.0 : 48.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 18, 16, compact ? 14 : 18, 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: SkinTokens.shadows,
            ),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const Key('help-back'),
                onTap: () => Navigator.of(context).pop(),
                child: Tooltip(
                  message: 'Kembali',
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: SkinHelpPage._deepTeal,
                      size: 32,
                    ),
                  ),
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
                fontSize: compact ? 22 : 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(width: size),
        ],
      ),
    );
  }
}

// ───────────────────────── Welcome ─────────────────────────

class _WelcomeCard extends StatelessWidget {
  final bool compact;

  const _WelcomeCard({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: compact ? 52 : 60,
            height: compact ? 52 : 60,
            decoration: BoxDecoration(
              color: SkinHelpPage._teal.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: SkinHelpPage._deepTeal,
              size: compact ? 28 : 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ada yang bisa kami bantu?',
                  style: TextStyle(
                    color: SkinHelpPage._navy,
                    fontSize: compact ? 17 : 19,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Panduan penggunaan, privasi, dan jawaban untuk pertanyaanmu.',
                  style: SkinTokens.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Topics panel ─────────────────────────

class _HelpTopicsPanel extends StatelessWidget {
  const _HelpTopicsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SkinTokens.radius),
        boxShadow: SkinTokens.shadows,
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkinTokens.radius),
        ),
        child: const Column(
          children: [
            _HelpTopic(
              key: Key('help-how-to'),
              icon: Icons.auto_awesome_rounded,
              color: SkinHelpPage._teal,
              title: 'Cara menggunakan SkinSight',
              subtitle: 'Panduan scan kulit dari awal sampai hasil.',
              initiallyExpanded: true,
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
              icon: Icons.mail_outline_rounded,
              color: SkinHelpPage._coral,
              title: 'Hubungi kami',
              subtitle: 'Butuh bantuan lebih lanjut? Tim kami siap.',
              child: _ContactContent(),
            ),
            _TopicDivider(),
            _HelpTopic(
              key: Key('help-privacy'),
              icon: Icons.privacy_tip_outlined,
              color: SkinHelpPage._deepTeal,
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
      thickness: 1,
      indent: 76,
      endIndent: 18,
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
  final bool initiallyExpanded;

  const _HelpTopic({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: color.withValues(alpha: .06),
        highlightColor: color.withValues(alpha: .04),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.fromLTRB(16, 8, 14, 8),
        childrenPadding: const EdgeInsets.fromLTRB(18, 2, 18, 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.centerLeft,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 23),
        ),
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
              fontSize: 13.5,
              height: 1.3,
            ),
          ),
        ),
        iconColor: SkinHelpPage._deepTeal,
        collapsedIconColor: SkinTokens.muted,
        children: [child],
      ),
    );
  }
}

// ───────────────────────── How to (timeline) ─────────────────────────

class _HowToContent extends StatelessWidget {
  const _HowToContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _StepRow(
          1,
          'Isi kuis kondisi kulit',
          'Jawab lima pertanyaan singkat sesuai kondisi wajahmu.',
        ),
        _StepRow(
          2,
          'Ambil selfie',
          'Posisikan wajah di dalam frame dengan cahaya yang cukup.',
        ),
        _StepRow(
          3,
          'Lihat hasil',
          'Baca ringkasan kondisi kulit dan panduan perawatanmu.',
          isLast: true,
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String title;
  final String body;
  final bool isLast;

  const _StepRow(this.number, this.title, this.body, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: SkinHelpPage._teal,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: SkinHelpPage._teal.withValues(alpha: .25),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: SkinHelpPage._navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    body,
                    style: const TextStyle(
                      color: SkinTokens.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── FAQ ─────────────────────────

class _FaqContent extends StatelessWidget {
  const _FaqContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _FaqItem(
          'Apakah hasil SkinSight merupakan diagnosis medis?',
          'Tidak. Hasil bersifat skrining awal dan edukasi, bukan pengganti pemeriksaan dokter kulit.',
        ),
        SizedBox(height: 8),
        _FaqItem(
          'Bagaimana agar hasil foto lebih baik?',
          'Gunakan cahaya dari depan, bersihkan lensa, dan hindari filter atau riasan tebal.',
        ),
        SizedBox(height: 8),
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
    return Container(
      decoration: BoxDecoration(
        color: SkinTokens.blue.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedAlignment: Alignment.centerLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: SkinTokens.blue,
          collapsedIconColor: SkinTokens.muted,
          title: Text(
            question,
            style: const TextStyle(
              color: SkinHelpPage._navy,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                color: SkinTokens.muted,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Contact ─────────────────────────

class _ContactContent extends StatelessWidget {
  const _ContactContent();

  @override
  Widget build(BuildContext context) {
    const email = 'support@skinsight.app';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: SkinHelpPage._coral.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alternate_email_rounded,
              color: SkinHelpPage._coral,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email dukungan',
                  style: TextStyle(
                    color: SkinTokens.muted,
                    fontSize: 12.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    color: SkinHelpPage._navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            key: const Key('copy-support-email'),
            tooltip: 'Salin email',
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: email));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Email dukungan berhasil disalin.'),
                  ),
                );
            },
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Privacy ─────────────────────────

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _PrivacyPoint(
          Icons.phone_android_rounded,
          'Foto digunakan untuk menampilkan hasil analisis pada perangkatmu.',
        ),
        _PrivacyPoint(
          Icons.save_outlined,
          'Hasil hanya disimpan ketika kamu memilih tombol Simpan.',
        ),
        _PrivacyPoint(
          Icons.share_outlined,
          'Jangan membagikan hasil yang memuat informasi pribadi kepada pihak yang tidak dipercaya.',
          isLast: true,
        ),
      ],
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;

  const _PrivacyPoint(this.icon, this.text, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: SkinHelpPage._deepTeal.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: SkinHelpPage._deepTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                text,
                style: const TextStyle(
                  color: SkinTokens.muted,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── About ─────────────────────────

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SkinSight membantu pengguna mengenali kondisi kulit melalui kuis dan foto wajah dengan pengalaman yang ringan dan mudah dipahami.',
          style: TextStyle(color: SkinTokens.muted, height: 1.45),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: SkinHelpPage._deepTeal.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Versi 1.1.0',
            style: TextStyle(
              color: SkinHelpPage._deepTeal,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Disclaimer ─────────────────────────

class _DisclaimerNote extends StatelessWidget {
  const _DisclaimerNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.health_and_safety_outlined,
            size: 18,
            color: SkinTokens.muted,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'SkinSight hanya untuk skrining awal dan edukasi. Untuk keluhan kulit yang berlanjut, konsultasikan ke dokter kulit.',
              style: TextStyle(
                color: SkinTokens.muted,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}