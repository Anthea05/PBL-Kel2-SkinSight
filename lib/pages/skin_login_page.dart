import 'package:flutter/material.dart';

class SkinLoginPage extends StatefulWidget {
  const SkinLoginPage({super.key});

  @override
  State<SkinLoginPage> createState() => _SkinLoginPageState();
}

class _SkinLoginPageState extends State<SkinLoginPage> {
  static const _deepTeal = Color(0xFF064E48);
  static const _teal = Color(0xFF168F7C);
  static const _navy = Color(0xFF142D35);
  static const _muted = Color(0xFF73898B);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'alea@skinsight.id');
  final _passwordController = TextEditingController(text: 'skinsight123');
  final _scrollController = ScrollController();

  bool _obscurePassword = true;
  bool _registerMode = false;

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
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  void _continueWithGoogle() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

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
      backgroundColor: const Color(0xFFF7FBF7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'lib/assets/images/start_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              ColoredBox(color: Colors.white.withValues(alpha: .26)),
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
                                const _LoginBrand(),
                                SizedBox(height: compact ? 24 : 34),
                                _LoginAvatar(compact: compact),
                                SizedBox(height: compact ? 16 : 20),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
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
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -.7,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _registerMode
                                            ? 'Mulai kenali kondisi kulitmu dengan akun baru.'
                                            : 'Masuk untuk melanjutkan perjalanan kulitmu.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _muted,
                                          fontSize: compact ? 13 : 14,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: compact ? 22 : 28),
                                if (_registerMode) ...[
                                  _AuthField(
                                    fieldKey: const Key('register-name'),
                                    controller: _nameController,
                                    label: 'Nama lengkap',
                                    icon: Icons.person_outline_rounded,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
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
                                  keyboardType: TextInputType.emailAddress,
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
                                    key: const Key('login-password-visibility'),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    tooltip: _obscurePassword
                                        ? 'Tampilkan password'
                                        : 'Sembunyikan password',
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
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
                                  label: _registerMode ? 'Daftar' : 'Masuk',
                                  onTap: _continueToHome,
                                ),
                                if (!_registerMode) ...[
                                  const SizedBox(height: 18),
                                  const _OrDivider(),
                                  const SizedBox(height: 18),
                                  _GoogleButton(onTap: _continueWithGoogle),
                                ],
                                const Spacer(),
                                const SizedBox(height: 24),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
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
                                      key: const Key('login-register-toggle'),
                                      onPressed: _toggleMode,
                                      child: Text(
                                        _registerMode ? 'Masuk' : 'Daftar',
                                        style: const TextStyle(
                                          color: _deepTeal,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
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
    );
  }
}

class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _LoginAvatar extends StatelessWidget {
  final bool compact;

  const _LoginAvatar({required this.compact});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 104.0 : 124.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .72),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _SkinLoginPageState._teal.withValues(alpha: .13),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Image.asset(
          'lib/assets/images/start_avatar.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
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
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDCEBE7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
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
  final String label;
  final VoidCallback onTap;

  const _PrimaryAuthButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('login-submit'),
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: _SkinLoginPageState._teal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(57),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: const Key('login-google'),
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _SkinLoginPageState._navy,
        backgroundColor: Colors.white.withValues(alpha: .92),
        minimumSize: const Size.fromHeight(55),
        side: const BorderSide(color: Color(0xFFD8E7E3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
        fontWeight: FontWeight.w900,
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
        Expanded(child: Divider(color: Color(0xFFD7E4E1))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 13),
          child:
              Text('atau', style: TextStyle(color: _SkinLoginPageState._muted)),
        ),
        Expanded(child: Divider(color: Color(0xFFD7E4E1))),
      ],
    );
  }
}
