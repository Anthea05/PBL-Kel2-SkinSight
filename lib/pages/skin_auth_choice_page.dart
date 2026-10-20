import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../theme/skin_theme.dart';

class SkinAuthChoicePage extends StatelessWidget {
  const SkinAuthChoicePage({super.key});

  void _registerWithGoogle(BuildContext context) {
    AuthSession.instance.signIn();
    Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDF3EE),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final panelTop = constraints.maxHeight * .62;
                return SingleChildScrollView(
                  key: const Key('auth-choice-scroll'),
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          height: panelTop + 42,
                          child: const _AuthChoiceHero(),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: panelTop),
                            _AuthChoicePanel(
                              onGoogle: () => _registerWithGoogle(context),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _AuthChoiceHero extends StatelessWidget {
  const _AuthChoiceHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'lib/assets/images/kawaii_mint_explorer_in_bubbles.png',
          fit: BoxFit.cover,
          alignment: const Alignment(0, -.04),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0x2607594F)],
              stops: [.72, 1],
            ),
          ),
        ),
        Positioned(
          left: 14,
          top: 10,
          child: Material(
            color: Colors.white.withValues(alpha: .86),
            shape: const CircleBorder(),
            child: IconButton(
              key: const Key('auth-choice-back'),
              tooltip: 'Kembali',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthChoicePanel extends StatelessWidget {
  const _AuthChoicePanel({
    required this.onGoogle,
  });

  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 700;
    return Container(
      key: const Key('auth-choice-panel'),
      padding: EdgeInsets.fromLTRB(
        compact ? 20 : 28,
        compact ? 17 : 19,
        compact ? 20 : 28,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mulai bersama SkinSight',
            style: TextStyle(
              color: SkinTokens.ink,
              fontSize: compact ? 24 : 27,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -.6,
            ),
          ),
          SizedBox(height: compact ? 14 : 16),
          OutlinedButton(
            key: const Key('auth-google'),
            onPressed: onGoogle,
            style: OutlinedButton.styleFrom(
              foregroundColor: SkinTokens.ink,
              backgroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: SkinTokens.primary, width: 1.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SkinTokens.radius),
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'G',
                    style: TextStyle(
                      color: Color(0xFF4285F4),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 11),
                  Text('Lanjut dengan Google'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const Key('auth-email'),
            onPressed: () => Navigator.of(context).pushNamed('/register'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SkinTokens.radius),
              ),
            ),
            icon: const Icon(Icons.mail_outline_rounded),
            label: const Text('Lanjut dengan Email'),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Sudah punya akun?', style: SkinTokens.caption),
              TextButton(
                key: const Key('auth-login'),
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                child: const Text('Masuk'),
              ),
            ],
          ),
          const SizedBox(height: 1),
          const Divider(color: SkinTokens.border),
          const SizedBox(height: 2),
          const _AuthLegalLinks(),
        ],
      ),
    );
  }
}

class _AuthLegalLinks extends StatelessWidget {
  const _AuthLegalLinks();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2,
      runSpacing: 0,
      children: [
        TextButton(
          key: const Key('auth-open-privacy'),
          onPressed: () => Navigator.of(context).pushNamed('/privacy'),
          child: const Text('Kebijakan Privasi'),
        ),
        TextButton(
          key: const Key('auth-open-terms'),
          onPressed: () => Navigator.of(context).pushNamed('/terms'),
          child: const Text('Syarat & Ketentuan'),
        ),
      ],
    );
  }
}
