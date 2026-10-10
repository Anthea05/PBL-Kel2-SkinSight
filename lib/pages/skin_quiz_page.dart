import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'skin_scan_page.dart';

class SkinQuizPage extends StatefulWidget {
  final bool enableCamera;

  const SkinQuizPage({super.key, this.enableCamera = true});

  @override
  State<SkinQuizPage> createState() => _SkinQuizPageState();
}

class _SkinQuizPageState extends State<SkinQuizPage> {
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
  // FR-05: tanpa jawaban terisi otomatis.
  final List<int?> _answers = [null, null, null, null, null];

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
      });
      return;
    }

    // FR-06: jawaban quiz dikirim sebagai konteks ke model.
    final answers = _answers.map((e) => e!).toList();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SkinScanPage(
          enableCamera: widget.enableCamera,
          quizAnswers: answers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _BreezeBlobs()),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 350;
                    final hPad = compact ? 16.0 : 20.0;
                    return Column(
                      children: [
                        _BreezeTopBar(
                          current: _currentQuestion + 1,
                          total: _questions.length,
                          hPad: hPad,
                          onClose: () =>
                              Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics:
                                const ClampingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                                hPad, 10, hPad, 12),
                            child: Column(
                              children: [
                                const SizedBox(height: 32),
                                Text(
                                  question.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        compact ? 20 : 22,
                                    height: 1.3,
                                    color: AppTokens.navy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  question.subtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Color(0xFF7B8B95),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                ...List.generate(
                                  question.answers.length,
                                  (index) => Padding(
                                    padding:
                                        const EdgeInsets.only(
                                            bottom: 12),
                                    child: _BreezeOption(
                                      key: Key(
                                          'quiz-answer-$index'),
                                      answer: question
                                          .answers[index],
                                      selected:
                                          _answers[_currentQuestion] ==
                                              index,
                                      onTap: () =>
                                          _selectAnswer(index),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              hPad, 4, hPad, 14),
                          child: _BreezeNextButton(
                            isLast: _currentQuestion ==
                                _questions.length - 1,
                            enabled:
                                _answers[_currentQuestion] !=
                                    null,
                            onTap: _continue,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreezeTopBar extends StatelessWidget {
  final int current;
  final int total;
  final double hPad;
  final VoidCallback onClose;

  const _BreezeTopBar({
    required this.current,
    required this.total,
    required this.hPad,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 6),
      child: Row(
        children: [
          Text(
            '$current/$total',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTokens.navy,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTokens.teal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: current / total,
                color: AppTokens.teal,
                backgroundColor:
                    const Color(0xFFE4EAEF),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Color(0xFFE3EAF0)),
              ),
              child: InkWell(
                key: const Key('quiz-back'),
                onTap: onClose,
                customBorder: const CircleBorder(),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF8A9BA5),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreezeOption extends StatelessWidget {
  final _QuizAnswer answer;
  final bool selected;
  final VoidCallback onTap;

  const _BreezeOption({
    super.key,
    required this.answer,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${answer.title}. ${answer.description}',
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 13),
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppTokens.teal
                  : const Color(0xFFE3EAF0),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppTokens.teal
                        : const Color(0xFFA9CCE3),
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration:
                              const BoxDecoration(
                            color: AppTokens.teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      answer.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _BreezeNextButton extends StatelessWidget {
  final bool isLast;
  final bool enabled;
  final VoidCallback onTap;

  const _BreezeNextButton({
    required this.isLast,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('quiz-continue'),
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: enabled
                ? AppTokens.teal
                : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              isLast ? 'Selesai' : 'Lanjut',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BreezeBlobs extends CustomPainter {
  const _BreezeBlobs();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE4F0F7).withValues(alpha: .7)
      ..style = PaintingStyle.fill;
    // Blob kanan atas.
    final top = Path()
      ..moveTo(size.width * .45, 0)
      ..quadraticBezierTo(size.width * .7, size.height * .04,
          size.width, size.height * .02)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(top, paint);
    // Blob kiri bawah.
    final bottom = Path()
      ..moveTo(0, size.height * .72)
      ..quadraticBezierTo(size.width * .3, size.height * .78,
          size.width * .22, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        bottom,
        Paint()
          ..color =
              const Color(0xFFE4F0F7).withValues(alpha: .55)
          ..style = PaintingStyle.fill);
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
