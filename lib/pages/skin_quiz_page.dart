import 'package:flutter/material.dart';

import 'skin_scan_page.dart';

class SkinQuizPage extends StatefulWidget {
  final bool enableCamera;

  const SkinQuizPage({super.key, this.enableCamera = true});

  @override
  State<SkinQuizPage> createState() => _SkinQuizPageState();
}

class _SkinQuizPageState extends State<SkinQuizPage> {
  static const _teal = Color(0xFF168A78);
  static const _deepTeal = Color(0xFF087467);
  static const _navy = Color(0xFF13263A);
  static const _cream = Color(0xFFFFF8EB);
  static const _assetBase = 'lib/assets/images';

  static const _questions = <_QuizQuestion>[
    _QuizQuestion(
      title: 'Bagaimana rasa kulit wajahmu saat bangun pagi?',
      subtitle: 'Pilih satu yang paling menggambarkan.',
      answers: [
        _QuizAnswer(
            'Berminyak di T-Zone', 'Dahi dan hidung mengilap, pipi normal.'),
        _QuizAnswer(
            'Mengilap di seluruh wajah', 'Terasa licin dari dahi sampai pipi.'),
        _QuizAnswer(
            'Kering dan ketarik', 'Kusam, bersisik, atau terasa perih.'),
        _QuizAnswer('Lembap pas', 'Tidak berminyak dan tidak terasa kencang.'),
      ],
    ),
    _QuizQuestion(
      title: 'Seberapa sering kulitmu terasa sensitif?',
      subtitle: 'Pilih kondisi yang paling sering kamu alami.',
      answers: [
        _QuizAnswer(
            'Hampir tidak pernah', 'Kulit terasa nyaman sepanjang hari.'),
        _QuizAnswer('Kadang-kadang', 'Biasanya setelah mencoba produk baru.'),
        _QuizAnswer('Cukup sering', 'Mudah merah, gatal, atau terasa panas.'),
        _QuizAnswer('Sangat sering', 'Kulit bereaksi meski tanpa produk baru.'),
      ],
    ),
    _QuizQuestion(
      title: 'Bagaimana kondisi pori-porimu?',
      subtitle: 'Perhatikan area hidung, dahi, dan pipi.',
      answers: [
        _QuizAnswer(
            'Hampir tidak terlihat', 'Pori tampak kecil dan cukup merata.'),
        _QuizAnswer(
            'Terlihat di hidung', 'Lebih jelas di sekitar hidung saja.'),
        _QuizAnswer('Terlihat di T-Zone', 'Tampak pada hidung dan dahi.'),
        _QuizAnswer(
            'Terlihat di banyak area', 'Pori terlihat sampai area pipi.'),
      ],
    ),
    _QuizQuestion(
      title: 'Masalah kulit apa yang paling mengganggumu?',
      subtitle: 'Pilih satu prioritas perawatanmu saat ini.',
      answers: [
        _QuizAnswer('Jerawat dan komedo', 'Muncul aktif atau berulang.'),
        _QuizAnswer(
            'Kusam dan tidak merata', 'Wajah tampak lelah atau belang.'),
        _QuizAnswer('Kering dan dehidrasi', 'Butuh kelembapan lebih lama.'),
        _QuizAnswer('Garis halus', 'Tekstur mulai tampak kurang kenyal.'),
      ],
    ),
    _QuizQuestion(
      title: 'Berapa lama kamu berada di luar ruangan?',
      subtitle: 'Perkirakan aktivitas harianmu di bawah matahari.',
      answers: [
        _QuizAnswer('Kurang dari 30 menit',
            'Sebagian besar aktivitas di dalam ruangan.'),
        _QuizAnswer('30 menit–1 jam', 'Keluar untuk perjalanan singkat.'),
        _QuizAnswer('1–3 jam', 'Cukup sering beraktivitas di luar.'),
        _QuizAnswer(
            'Lebih dari 3 jam', 'Banyak aktivitas langsung di luar ruangan.'),
      ],
    ),
  ];

  int _currentQuestion = 0;
  final List<int?> _answers = [0, null, null, null, null];

  void _selectAnswer(int index) {
    setState(() => _answers[_currentQuestion] = index);
  }

  void _continue() {
    if (_answers[_currentQuestion] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih salah satu jawaban terlebih dahulu.')),
      );
      return;
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion += 1;
        _answers[_currentQuestion] ??= 0;
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SkinScanPage(enableCamera: widget.enableCamera),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 350;

                return DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1FC1ED),
                        Color(0xFF8DE2F3),
                        _cream,
                      ],
                      stops: [0, .48, 1],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: _QuizBackgroundPainter()),
                        ),
                      ),
                      Column(
                        children: [
                          _QuizHeader(
                            current: _currentQuestion + 1,
                            total: _questions.length,
                            compact: compact,
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                compact ? 12 : 18,
                                8,
                                compact ? 12 : 18,
                                24,
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        right: compact ? -6 : 0,
                                        top: 0,
                                        width: compact ? 122 : 150,
                                        height: compact ? 150 : 178,
                                        child: Image.asset(
                                          '$_assetBase/skin_girl.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: compact ? 104 : 122,
                                        ),
                                        child: _QuestionCard(
                                          questionNumber: _currentQuestion + 1,
                                          question: question,
                                          selectedIndex:
                                              _answers[_currentQuestion],
                                          compact: compact,
                                          onSelected: _selectAnswer,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: _ContinueButton(
                                      compact: compact,
                                      isLast: _currentQuestion ==
                                          _questions.length - 1,
                                      onTap: _continue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizHeader extends StatelessWidget {
  final int current;
  final int total;
  final bool compact;
  final VoidCallback onBack;

  const _QuizHeader({
    required this.current,
    required this.total,
    required this.compact,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 18, 16, compact ? 14 : 18, 8),
      child: Column(
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: .94),
                shape: const CircleBorder(),
                child: InkWell(
                  key: const Key('quiz-back'),
                  onTap: onBack,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: compact ? 46 : 52,
                    height: compact ? 46 : 52,
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: _SkinQuizPageState._deepTeal,
                      size: 34,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kuis Kondisi Kulit',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    color: _SkinQuizPageState._navy,
                    fontSize: compact ? 21 : 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(
                width: compact ? 54 : 62,
                child: Text(
                  '$current / $total',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _SkinQuizPageState._navy,
                    fontSize: compact ? 17 : 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: compact ? 10 : 12,
              value: current / total,
              color: _SkinQuizPageState._teal,
              backgroundColor: Colors.white.withValues(alpha: .68),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int questionNumber;
  final _QuizQuestion question;
  final int? selectedIndex;
  final bool compact;
  final ValueChanged<int> onSelected;

  const _QuestionCard({
    required this.questionNumber,
    required this.question,
    required this.selectedIndex,
    required this.compact,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .98),
        borderRadius: BorderRadius.circular(compact ? 28 : 34),
        border: Border.all(
          color: _SkinQuizPageState._deepTeal.withValues(alpha: .08),
        ),
        boxShadow: [
          BoxShadow(
            color: _SkinQuizPageState._deepTeal.withValues(alpha: .11),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F7F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Pertanyaan $questionNumber',
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                color: _SkinQuizPageState._teal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(height: compact ? 17 : 22),
          Text(
            question.title,
            style: TextStyle(
              fontSize: compact ? 23 : 28,
              height: 1.17,
              color: _SkinQuizPageState._navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            question.subtitle,
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              color: const Color(0xFF65798C),
            ),
          ),
          SizedBox(height: compact ? 18 : 22),
          ...List.generate(question.answers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnswerTile(
                answer: question.answers[index],
                selected: selectedIndex == index,
                compact: compact,
                onTap: () => onSelected(index),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final _QuizAnswer answer;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _AnswerTile({
    required this.answer,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 13 : 16,
            vertical: compact ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0FBF8) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  selected ? _SkinQuizPageState._teal : const Color(0xFFDCE4E9),
              width: selected ? 2 : 1.4,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: compact ? 34 : 40,
                height: compact ? 34 : 40,
                decoration: BoxDecoration(
                  color: selected ? _SkinQuizPageState._teal : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? _SkinQuizPageState._teal
                        : const Color(0xFF9AAAB6),
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer.title,
                      style: TextStyle(
                        fontSize: compact ? 15 : 17,
                        color: _SkinQuizPageState._navy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      answer.description,
                      style: TextStyle(
                        fontSize: compact ? 12 : 14,
                        height: 1.25,
                        color: const Color(0xFF65798C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool compact;
  final bool isLast;
  final VoidCallback onTap;

  const _ContinueButton({
    required this.compact,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('quiz-continue'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Ink(
          width: compact ? double.infinity : 248,
          height: compact ? 62 : 68,
          padding: const EdgeInsets.fromLTRB(24, 7, 8, 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_SkinQuizPageState._teal, _SkinQuizPageState._deepTeal],
            ),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: _SkinQuizPageState._deepTeal.withValues(alpha: .20),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isLast ? 'Selesai' : 'Lanjut',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 20 : 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                width: compact ? 46 : 52,
                height: compact ? 46 : 52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: _SkinQuizPageState._deepTeal,
                  size: 29,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizBackgroundPainter extends CustomPainter {
  const _QuizBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: .34);
    canvas.drawCircle(
        Offset(size.width * .08, size.height * .24), 38, bubblePaint);
    canvas.drawCircle(
        Offset(size.width * .88, size.height * .16), 18, bubblePaint);
    canvas.drawCircle(
        Offset(size.width * .34, size.height * .20), 27, bubblePaint);

    final moleculePaint = Paint()
      ..color = Colors.white.withValues(alpha: .28)
      ..strokeWidth = 1.4;
    final a = Offset(size.width * .10, size.height * .15);
    final b = Offset(size.width * .16, size.height * .11);
    final c = Offset(size.width * .23, size.height * .15);
    canvas.drawLine(a, b, moleculePaint);
    canvas.drawLine(b, c, moleculePaint);
    for (final point in [a, b, c]) {
      canvas.drawCircle(point, 5, moleculePaint);
    }

    final skinPaint = Paint()
      ..color = const Color(0xFFFFB43B).withValues(alpha: .10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(-20, size.height * .93)
      ..quadraticBezierTo(
        size.width * .35,
        size.height * .84,
        size.width * .65,
        size.height * .94,
      )
      ..quadraticBezierTo(
        size.width * .83,
        size.height,
        size.width + 20,
        size.height * .91,
      );
    canvas.drawPath(path, skinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuizQuestion {
  final String title;
  final String subtitle;
  final List<_QuizAnswer> answers;

  const _QuizQuestion({
    required this.title,
    required this.subtitle,
    required this.answers,
  });
}

class _QuizAnswer {
  final String title;
  final String description;

  const _QuizAnswer(this.title, this.description);
}
