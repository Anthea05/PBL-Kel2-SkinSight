import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../theme/skin_theme.dart';

class SkinOnboardingPage extends StatefulWidget {
  const SkinOnboardingPage({super.key});

  @override
  State<SkinOnboardingPage> createState() => _SkinOnboardingPageState();
}

class _SkinOnboardingPageState extends State<SkinOnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = <_OnboardingSlideData>[
    _OnboardingSlideData(
      imagePath: 'lib/assets/images/onboarding_1.png',
      title: 'Kenali kondisi kulitmu',
      body: 'Ambil foto wajah untuk melihat ringkasan temuan visual kulitmu.',
    ),
    _OnboardingSlideData(
      imagePath: 'lib/assets/images/onboarding_2.png',
      title: 'Pantau perjalanan kulitmu',
      body:
          'Simpan hasil scan dan lihat perkembangan kulitmu dari waktu ke waktu.',
    ),
    _OnboardingSlideData(
      imagePath: 'lib/assets/images/onboarding_3.png',
      title: 'Check-in rutin lebih mudah',
      body:
          'Isi check-in singkat dan tambah foto pemantauan untuk membantu perjalanan kulitmu.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    AuthSession.instance.completeOnboarding();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  void _next() {
    if (_index == _slides.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      key: const Key('onboarding-page'),
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF1FAF7)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        key: const Key('onboarding-skip'),
                        onPressed: _finish,
                        child: const Text('Lewati'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      key: const Key('onboarding-slides'),
                      controller: _controller,
                      itemCount: _slides.length,
                      onPageChanged: (value) => setState(() => _index = value),
                      itemBuilder: (context, index) =>
                          _OnboardingSlide(data: _slides[index]),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < _slides.length; index++)
                        AnimatedContainer(
                          key: Key('onboarding-dot-$index'),
                          duration: const Duration(milliseconds: 180),
                          width: index == _index ? 22 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index == _index
                                ? SkinTokens.primary
                                : const Color(0xFFCFE3DE),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('onboarding-next'),
                        onPressed: _next,
                        child: Text(isLast ? 'Mulai' : 'Berikutnya'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data});

  final _OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compact = screenHeight < 650;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, compact ? 0 : 8, 24, compact ? 10 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            key: Key('onboarding-title-${data.imagePath}'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: SkinTokens.ink,
                  fontSize: compact ? 26 : 30,
                  fontWeight: FontWeight.w700,
                  height: 1.12,
                ),
          ),
          SizedBox(height: compact ? 10 : 16),
          Expanded(
            child: Center(
              child: Image.asset(
                data.imagePath,
                key: Key('onboarding-image-${data.imagePath}'),
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: compact ? 10 : 16),
          Text(
            data.body,
            key: Key('onboarding-body-${data.imagePath}'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: SkinTokens.muted,
                  fontSize: compact ? 15 : 16,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.imagePath,
    required this.title,
    required this.body,
  });

  final String imagePath;
  final String title;
  final String body;
}
