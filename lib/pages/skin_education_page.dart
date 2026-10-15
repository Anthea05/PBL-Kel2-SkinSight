import 'package:flutter/material.dart';

import '../theme/skin_theme.dart';
import '../widgets/skin_bottom_nav.dart';

class SkinEducationPage extends StatefulWidget {
  final bool embedded;

  const SkinEducationPage({super.key, this.embedded = false});

  @override
  State<SkinEducationPage> createState() => _SkinEducationPageState();
}

class _SkinEducationPageState extends State<SkinEducationPage> {
  static const _background = Color(0xFFFFF8EB);
  static const _ink = SkinTokens.ink;
  static const _topics = <String>[
    'Semua',
    'Acne',
    'PIH',
    'Dark Circle',
    'Redness',
    'Wrinkle',
  ];

  final _searchController = TextEditingController();
  String _selectedTopic = 'Semua';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_EducationArticle> get _filteredArticles {
    final normalizedQuery = _query.trim().toLowerCase();
    return _articles.where((article) {
      final topicMatches =
          _selectedTopic == 'Semua' || article.topic == _selectedTopic;
      final queryMatches = normalizedQuery.isEmpty ||
          article.title.toLowerCase().contains(normalizedQuery) ||
          article.summary.toLowerCase().contains(normalizedQuery) ||
          article.topic.toLowerCase().contains(normalizedQuery);
      return topicMatches && queryMatches;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final articles = _filteredArticles;
    final showFeatured = articles.contains(_featuredArticle);
    final readingList = articles
        .where((article) => article != _featuredArticle)
        .toList(growable: false);

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
        child: CustomScrollView(
          key: const Key('education-scroll'),
          physics: const ClampingScrollPhysics(),
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(child: _EducationIntro()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 13),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _topics.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final topic = _topics[index];
                      return _TopicChip(
                        topic: topic,
                        selected: topic == _selectedTopic,
                        onSelected: () =>
                            setState(() => _selectedTopic = topic),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (showFeatured) ...[
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: _SectionLabel(
                    title: 'Artikel rekomendasi',
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _FeaturedArticle(
                    article: _featuredArticle,
                    onTap: () => _showArticle(context, _featuredArticle),
                  ),
                ),
              ),
            ],
            if (readingList.isNotEmpty) ...[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  showFeatured ? 28 : 30,
                  20,
                  8,
                ),
                sliver: const SliverToBoxAdapter(
                  child: _SectionLabel(
                    title: 'Jelajahi topik kulit',
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: readingList.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: Color(0xFFD8E1DD),
                  ),
                  itemBuilder: (context, index) {
                    final article = readingList[index];
                    return _ArticleRow(
                      article: article,
                      onTap: () => _showArticle(context, article),
                    );
                  },
                ),
              ),
            ],
            if (articles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyEducationState(
                  onReset: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                      _selectedTopic = 'Semua';
                    });
                  },
                ),
              ),
            if (articles.isNotEmpty)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 26, 20, 36),
                sliver: SliverToBoxAdapter(child: _EducationNote()),
              ),
          ],
        ),
      ),
    );

    if (widget.embedded) {
      return ColoredBox(color: _background, child: content);
    }

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(bottom: false, child: content),
      bottomNavigationBar: const SkinBottomNav(currentIndex: 1),
    );
  }

  void _showArticle(BuildContext context, _EducationArticle article) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _background,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .78,
        minChildSize: .55,
        maxChildSize: .94,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 34),
          children: [
            Row(
              children: [
                _TopicMark(article: article, compact: true),
                const SizedBox(width: 10),
                Text(
                  article.topic.toUpperCase(),
                  style: const TextStyle(
                    color: SkinTokens.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                Text(
                  article.readTime,
                  style: SkinTokens.caption,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              article.title,
              style: const TextStyle(
                color: _ink,
                fontSize: 27,
                height: 1.16,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              article.summary,
              style: const TextStyle(
                color: SkinTokens.muted,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: article.gradient,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -18,
                    width: 165,
                    child: Image.asset(
                      'lib/assets/images/skin_magnifier.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 22,
                    child: Icon(
                      article.icon,
                      size: 42,
                      color: _ink.withValues(alpha: .76),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text(
              article.body,
              style: const TextStyle(
                color: _ink,
                fontSize: 16,
                height: 1.62,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Yang perlu diingat', style: SkinTokens.section),
            const SizedBox(height: 12),
            for (final point in article.keyPoints)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: SkinTokens.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 15,
                          height: 1.48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Sumber bacaan: ${article.source}',
              style: const TextStyle(
                color: SkinTokens.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationIntro extends StatelessWidget {
  const _EducationIntro();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Edukasi',
      style: TextStyle(
        color: SkinTokens.ink,
        fontSize: 29,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -.6,
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        key: const Key('education-search'),
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari topik atau kebutuhan kulit',
          hintStyle: const TextStyle(color: Color(0xFF789095), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: SkinTokens.primary,
          ),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD8E5E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: SkinTokens.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String topic;
  final bool selected;
  final VoidCallback onSelected;

  const _TopicChip({
    required this.topic,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? SkinTokens.primary : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? SkinTokens.primary : const Color(0xFFC7D8D3),
        ),
      ),
      child: InkWell(
        key: Key('education-topic-${topic.toLowerCase().replaceAll(' ', '-')}'),
        onTap: onSelected,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            topic,
            style: TextStyle(
              color: selected ? Colors.white : SkinTokens.muted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String? eyebrow;
  final String title;

  const _SectionLabel({this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            style: const TextStyle(
              color: SkinTokens.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.35,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(title, style: SkinTokens.section),
      ],
    );
  }
}

class _FeaturedArticle extends StatelessWidget {
  final _EducationArticle article;
  final VoidCallback onTap;

  const _FeaturedArticle({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('education-featured'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: article.gradient,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 355;
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    right: compact ? -36 : -18,
                    bottom: -24,
                    width: compact ? 176 : 205,
                    child: Image.asset(
                      'lib/assets/images/skin_magnifier.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 22,
                    bottom: 20,
                    width: compact ? 192 : 225,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .82),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            article.topic,
                            style: const TextStyle(
                              color: SkinTokens.primaryDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          article.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: SkinTokens.ink,
                            fontSize: compact ? 20 : 22,
                            height: 1.12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Baca  •  ${article.readTime}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: SkinTokens.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                              color: SkinTokens.primaryDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  final _EducationArticle article;
  final VoidCallback onTap;

  const _ArticleRow({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('education-article-${article.slug}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TopicMark(article: article),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          article.topic.toUpperCase(),
                          style: const TextStyle(
                            color: SkinTokens.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .85,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          article.readTime,
                          style: const TextStyle(
                            color: Color(0xFF7A8D90),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SkinTokens.ink,
                        fontSize: 16,
                        height: 1.24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SkinTokens.muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 19,
                color: Color(0xFF70878A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicMark extends StatelessWidget {
  final _EducationArticle article;
  final bool compact;

  const _TopicMark({required this.article, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 58.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: article.gradient,
        ),
        borderRadius: BorderRadius.circular(compact ? 11 : 17),
      ),
      child: Icon(
        article.icon,
        size: compact ? 18 : 27,
        color: SkinTokens.ink.withValues(alpha: .78),
      ),
    );
  }
}

class _EmptyEducationState extends StatelessWidget {
  final VoidCallback onReset;

  const _EmptyEducationState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 38, 36, 110),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.manage_search_rounded,
            size: 52,
            color: SkinTokens.primary,
          ),
          const SizedBox(height: 14),
          const Text(
            'Topik belum ditemukan',
            style: SkinTokens.section,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          const Text(
            'Coba kata kunci lain atau tampilkan kembali semua topik.',
            textAlign: TextAlign.center,
            style: SkinTokens.caption,
          ),
          const SizedBox(height: 14),
          TextButton(
              onPressed: onReset, child: const Text('Lihat semua topik')),
        ],
      ),
    );
  }
}

class _EducationNote extends StatelessWidget {
  const _EducationNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 19,
          color: SkinTokens.primary,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Konten ini bersifat edukasi umum. Hasil foto dan artikel tidak menggantikan diagnosis atau saran tenaga kesehatan.',
            style: TextStyle(
              color: SkinTokens.muted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _EducationArticle {
  final String slug;
  final String topic;
  final String title;
  final String summary;
  final String body;
  final String readTime;
  final String source;
  final IconData icon;
  final List<Color> gradient;
  final List<String> keyPoints;

  const _EducationArticle({
    required this.slug,
    required this.topic,
    required this.title,
    required this.summary,
    required this.body,
    required this.readTime,
    required this.source,
    required this.icon,
    required this.gradient,
    required this.keyPoints,
  });
}

const _featuredArticle = _EducationArticle(
  slug: 'sunscreen-setiap-hari',
  topic: 'PIH',
  title: 'Sunscreen dan noda gelap: hubungan yang perlu kamu tahu',
  summary:
      'Perlindungan UV membantu mencegah noda tampak makin gelap dan mendukung perawatan yang konsisten.',
  body:
      'Paparan sinar matahari dapat membuat hiperpigmentasi pascainflamasi tampak lebih gelap. Karena itu, perlindungan UV menjadi bagian penting dari rutinitas harian. Pilih sunscreen yang nyaman digunakan, aplikasikan dengan merata saat akan terpapar matahari, dan padukan dengan kebiasaan mencari teduh atau memakai pelindung fisik bila diperlukan.',
  readTime: '4 menit',
  source: 'American Academy of Dermatology (AAD)',
  icon: Icons.wb_sunny_outlined,
  gradient: [Color(0xFFBDE8EB), Color(0xFFFFE6B9)],
  keyPoints: [
    'Konsistensi penggunaan lebih penting daripada mengejar rutinitas yang terlalu rumit.',
    'Noda tidak memiliki satu waktu pudar yang sama untuk semua orang.',
    'Jika produk menimbulkan perih atau iritasi, catat reaksinya dan evaluasi penggunaannya.',
  ],
);

const _articles = <_EducationArticle>[
  _featuredArticle,
  _EducationArticle(
    slug: 'jerawat-tidak-hilang-semalam',
    topic: 'Acne',
    title: 'Mengapa jerawat tidak hilang dalam semalam?',
    summary:
        'Perawatan membutuhkan waktu, sementara memencet lesi dapat menambah risiko iritasi dan bekas.',
    body:
        'Jerawat terbentuk melalui proses yang tidak berhenti hanya dalam satu malam. Perubahan yang terlihat dari hari ke hari juga dapat dipengaruhi cahaya, sudut foto, dan kondisi kulit saat itu. Gunakan rutinitas yang lembut, hindari memencet lesi, dan nilai perubahan secara berkala dengan foto yang konsisten.',
    readTime: '3 menit',
    source: 'AAD dan NICE Acne Guideline NG198',
    icon: Icons.bubble_chart_outlined,
    gradient: [Color(0xFFFFD8D2), Color(0xFFFFEEE5)],
    keyPoints: [
      'Jangan menyimpulkan keberhasilan atau kegagalan dari satu hari atau satu foto.',
      'Jerawat yang dalam, sangat nyeri, atau berisiko meninggalkan parut perlu perhatian profesional.',
      'Tambahkan produk baru secara bertahap agar respons kulit lebih mudah diamati.',
    ],
  ),
  _EducationArticle(
    slug: 'foto-dark-circle-konsisten',
    topic: 'Dark Circle',
    title: 'Cahaya foto bisa mengubah tampilan area bawah mata',
    summary:
        'Bayangan, posisi wajah, dan pencahayaan perlu serupa sebelum dua foto dibandingkan.',
    body:
        'Tampilan lingkaran gelap dapat dipengaruhi pigmentasi, pembuluh darah, struktur wajah, atau gabungan beberapa faktor. Foto saja tidak dapat menentukan penyebabnya. Untuk dokumentasi, gunakan cahaya dari depan, ekspresi netral, dan jarak kamera yang sama.',
    readTime: '4 menit',
    source: 'Periorbital Hyperpigmentation Comprehensive Review',
    icon: Icons.remove_red_eye_outlined,
    gradient: [Color(0xFFD9D8F5), Color(0xFFECEBFA)],
    keyPoints: [
      'Bayangan yang berbeda dapat terlihat seperti perubahan kondisi.',
      'Hindari memilih bahan aktif dekat mata hanya berdasarkan satu foto.',
      'Catat juga keluhan yang kamu rasakan, bukan hanya tampilan visual.',
    ],
  ),
  _EducationArticle(
    slug: 'redness-dan-iritasi',
    topic: 'Redness',
    title: 'Saat kemerahan disertai rasa perih atau panas',
    summary:
        'Keluhan yang dirasakan sama pentingnya dengan area kemerahan yang terlihat pada foto.',
    body:
        'Kemerahan tidak selalu memiliki penyebab yang sama. Jika muncul setelah produk baru, hentikan eksperimen tambahan dan catat waktu serta produk yang digunakan. Perawatan lembut, pelembap yang nyaman, dan perlindungan UV dapat membantu menjaga skin barrier tanpa mengklaim diagnosis tertentu.',
    readTime: '3 menit',
    source: 'American Academy of Dermatology (AAD)',
    icon: Icons.health_and_safety_outlined,
    gradient: [Color(0xFFFFD6CE), Color(0xFFFFEAE3)],
    keyPoints: [
      'Perih, panas, bengkak, atau perubahan cepat tidak boleh diabaikan.',
      'Jangan menambah banyak bahan aktif saat kulit sedang teriritasi.',
      'Pertimbangkan bantuan profesional untuk keluhan sedang hingga berat.',
    ],
  ),
  _EducationArticle(
    slug: 'wrinkle-pose-netral',
    topic: 'Wrinkle',
    title: 'Mengamati garis halus tanpa terkecoh ekspresi',
    summary:
        'Pose netral dan perlindungan UV membuat dokumentasi garis halus lebih bermakna.',
    body:
        'Ekspresi wajah dapat mengubah garis yang terlihat pada foto. Bila ingin memantau perubahan, gunakan pose netral, pencahayaan, jarak, dan area wajah yang serupa. Hasil foto merupakan observasi teknis, bukan ukuran kedalaman kerutan secara klinis.',
    readTime: '4 menit',
    source: 'Systematic Review Tretinoin for Photoaging dan WSRS',
    icon: Icons.face_retouching_natural_outlined,
    gradient: [Color(0xFFCDE7DE), Color(0xFFEAF3DE)],
    keyPoints: [
      'Bandingkan foto hanya saat pose dan ekspresi benar-benar serupa.',
      'Perlindungan UV relevan untuk perawatan kulit jangka panjang.',
      'Riset perawatan berlangsung berbulan-bulan dan bukan janji hasil individual.',
    ],
  ),
  _EducationArticle(
    slug: 'rutinitas-lembut',
    topic: 'Acne',
    title: 'Rutinitas sederhana yang lebih mudah dipertahankan',
    summary:
        'Pembersih lembut, pelembap, dan perlindungan matahari adalah fondasi yang realistis.',
    body:
        'Rutinitas yang konsisten tidak harus panjang. Mulailah dari langkah dasar yang terasa nyaman, lalu ubah satu hal dalam satu waktu. Cara ini membantu kamu mengenali produk yang bekerja baik dan produk yang mungkin memicu iritasi.',
    readTime: '3 menit',
    source: 'AAD dan NICE Acne Guideline NG198',
    icon: Icons.spa_outlined,
    gradient: [Color(0xFFCFECE3), Color(0xFFEAF6ED)],
    keyPoints: [
      'Mulai dari langkah dasar sebelum menambah banyak produk.',
      'Perubahan bertahap membuat respons kulit lebih mudah ditelusuri.',
      'Ikuti arahan dokter bila kamu sedang berada dalam perawatan profesional.',
    ],
  ),
];
