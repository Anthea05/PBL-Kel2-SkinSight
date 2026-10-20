import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../theme/skin_theme.dart';
import '../widgets/skin_page_background.dart';

class SkinLoginPage extends StatefulWidget {
  const SkinLoginPage({super.key, this.initialRegisterMode = false});

  final bool initialRegisterMode;

  @override
  State<SkinLoginPage> createState() => _SkinLoginPageState();
}

class _SkinLoginPageState extends State<SkinLoginPage> {
  static const _deepTeal = SkinTokens.primaryDark;
  static const _teal = SkinTokens.primary;
  static const _navy = SkinTokens.ink;
  static const _muted = SkinTokens.muted;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'alea@skinsight.id');
  final _passwordController = TextEditingController(text: 'skinsight123');
  final _scrollController = ScrollController();

  bool _obscurePassword = true;
  late bool _registerMode;

  @override
  void initState() {
    super.initState();
    _registerMode = widget.initialRegisterMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _continueToHome() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    AuthSession.instance.signIn();
    final destination = _destinationAfterAuthentication;
    Navigator.of(context).pushNamedAndRemoveUntil(destination, (_) => false);
  }

  void _continueWithGoogle() {
    AuthSession.instance.signIn();
    final destination = _destinationAfterAuthentication;
    Navigator.of(context).pushNamedAndRemoveUntil(destination, (_) => false);
  }

  String get _destinationAfterAuthentication =>
      _registerMode || !AuthSession.instance.hasCompletedOnboarding
          ? '/onboarding'
          : '/home';

  void _toggleMode() {
    setState(() {
      _registerMode = !_registerMode;
      _formKey.currentState?.reset();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkinTokens.background,
      body: SkinPageBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: SkinTokens.maxWidth),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: Colors.white.withValues(alpha: .18)),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 350;
                      return SingleChildScrollView(
                        key: const Key('login-scroll'),
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          compact ? 20 : 28,
                          compact ? 24 : 36,
                          compact ? 20 : 28,
                          28,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight - (compact ? 52 : 64),
                          ),
                          child: IntrinsicHeight(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _LoginVisualHero(
                                    compact: compact,
                                    registerMode: _registerMode,
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                      compact ? 17 : 20,
                                      compact ? 20 : 24,
                                      compact ? 17 : 20,
                                      17,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: .92),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(color: Colors.white),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        AnimatedSwitcher(
                                          duration: Duration.zero,
                                          child: Column(
                                            key: ValueKey(_registerMode),
                                            children: [
                                              Text(
                                                _registerMode
                                                    ? 'Buat akun SkinSight'
                                                    : 'Selamat datang kembali',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: _navy,
                                                  fontSize: compact ? 25 : 29,
                                                  height: 1.08,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -.7,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _registerMode
                                                    ? 'Mulai kenali kondisi kulitmu dengan akun baru.'
                                                    : 'Masuk untuk melanjutkan perjalanan kulitmu.',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: _muted,
                                                  fontSize: 16,
                                                  height: 1.35,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: compact ? 22 : 28),
                                        if (!_registerMode) ...[
                                          _GoogleButton(
                                            onTap: _continueWithGoogle,
                                          ),
                                          const SizedBox(height: 18),
                                          const _OrDivider(),
                                          const SizedBox(height: 18),
                                        ],
                                        if (_registerMode) ...[
                                          _AuthField(
                                            fieldKey:
                                                const Key('register-name'),
                                            controller: _nameController,
                                            label: 'Nama lengkap',
                                            icon: Icons.person_outline_rounded,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: (value) =>
                                                value == null ||
                                                        value.trim().isEmpty
                                                    ? 'Nama perlu diisi.'
                                                    : null,
                                          ),
                                          const SizedBox(height: 13),
                                        ],
                                        _AuthField(
                                          fieldKey: const Key('login-email'),
                                          controller: _emailController,
                                          label: 'Alamat email',
                                          icon: Icons.mail_outline_rounded,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          validator: (value) {
                                            final email = value?.trim() ?? '';
                                            if (email.isEmpty) {
                                              return 'Email perlu diisi.';
                                            }
                                            if (!email.contains('@')) {
                                              return 'Masukkan alamat email yang valid.';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 13),
                                        _AuthField(
                                          fieldKey: const Key('login-password'),
                                          controller: _passwordController,
                                          label: 'Password',
                                          icon: Icons.lock_outline_rounded,
                                          obscureText: _obscurePassword,
                                          textInputAction: TextInputAction.done,
                                          onSubmitted: (_) => _continueToHome(),
                                          suffix: IconButton(
                                            key: const Key(
                                              'login-password-visibility',
                                            ),
                                            onPressed: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                            tooltip: _obscurePassword
                                                ? 'Tampilkan password'
                                                : 'Sembunyikan password',
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: _teal,
                                            ),
                                          ),
                                          validator: (value) {
                                            if ((value ?? '').length < 6) {
                                              return 'Password minimal 6 karakter.';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: compact ? 18 : 22),
                                        _PrimaryAuthButton(
                                          label: _registerMode
                                              ? 'Daftar'
                                              : 'Masuk',
                                          onTap: _continueToHome,
                                        ),
                                        const SizedBox(height: 24),
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              _registerMode
                                                  ? 'Sudah punya akun?'
                                                  : 'Belum punya akun?',
                                              style: const TextStyle(
                                                color: _muted,
                                                fontSize: 14,
                                              ),
                                            ),
                                            TextButton(
                                              key: const Key(
                                                'login-register-toggle',
                                              ),
                                              onPressed: _toggleMode,
                                              child: Text(
                                                _registerMode
                                                    ? 'Masuk'
                                                    : 'Daftar',
                                                style: const TextStyle(
                                                  color: _deepTeal,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const _LoginLegalLinks(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

class _LoginVisualHero extends StatelessWidget {
  const _LoginVisualHero({
    required this.compact,
    required this.registerMode,
  });

  final bool compact;
  final bool registerMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 180 : 215,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCBE8E3), Color(0xFFE6F2DE)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            right: compact ? -12 : 0,
            bottom: -10,
            width: compact ? 155 : 190,
            height: compact ? 165 : 205,
            child: Image.asset(
              'lib/assets/images/start_avatar.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned(
            left: 8,
            top: 7,
            child: IconButton(
              key: const Key('login-back'),
              tooltip: 'Kembali',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Positioned(
            left: 18,
            top: compact ? 57 : 66,
            width: compact ? 152 : 185,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _LoginBrand(),
                const SizedBox(height: 13),
                Text(
                  registerMode
                      ? 'Mulai catatan kulitmu.'
                      : 'Lanjutkan perjalananmu.',
                  style: TextStyle(
                    color: _SkinLoginPageState._navy,
                    fontSize: compact ? 18 : 22,
                    height: 1.16,
                    fontWeight: FontWeight.w800,
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

class _LoginLegalLinks extends StatelessWidget {
  const _LoginLegalLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: SkinTokens.border),
        const SizedBox(height: 5),
        const Text(
          'Dengan melanjutkan, kamu dapat membaca ketentuan berikut.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _SkinLoginPageState._muted,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 2),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 0,
          children: [
            TextButton(
              key: const Key('login-open-privacy'),
              onPressed: () => Navigator.of(context).pushNamed('/privacy'),
              child: const Text('Kebijakan Privasi'),
            ),
            TextButton(
              key: const Key('login-open-terms'),
              onPressed: () => Navigator.of(context).pushNamed('/terms'),
              child: const Text('Syarat & Ketentuan'),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.blur_circular_rounded, color: _SkinLoginPageState._teal),
            SizedBox(width: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Skin',
                    style: TextStyle(color: _SkinLoginPageState._deepTeal),
                  ),
                  TextSpan(
                    text: 'Sight',
                    style: TextStyle(color: _SkinLoginPageState._teal),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.onSubmitted,
    this.validator,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: const TextStyle(
        color: _SkinLoginPageState._navy,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _SkinLoginPageState._muted),
        prefixIcon: Icon(icon, color: _SkinLoginPageState._teal),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: .92),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SkinTokens.radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SkinTokens.radius),
          borderSide: const BorderSide(color: SkinTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SkinTokens.radius),
          borderSide: const BorderSide(
            color: _SkinLoginPageState._teal,
            width: 1.7,
          ),
        ),
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  const _PrimaryAuthButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('login-submit'),
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: _SkinLoginPageState._teal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkinTokens.radius),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: const Key('login-google'),
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _SkinLoginPageState._navy,
        backgroundColor: Colors.white.withValues(alpha: .92),
        minimumSize: const Size.fromHeight(55),
        side: const BorderSide(color: SkinTokens.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SkinTokens.radius),
        ),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GoogleMark(),
            SizedBox(width: 11),
            Text(
              'Masuk dengan Google',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: SkinTokens.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 13),
          child: Text(
            'atau',
            style: TextStyle(color: _SkinLoginPageState._muted),
          ),
        ),
        Expanded(child: Divider(color: SkinTokens.border)),
      ],
    );
  }
}
