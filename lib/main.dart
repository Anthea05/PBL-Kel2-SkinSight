import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/auth_service.dart';
import 'models/profile_data.dart';
import 'models/font_settings.dart';
import 'models/auth_session.dart';
import 'theme/skin_theme.dart';
import 'widgets/skin_page_background.dart';
import 'core/app_assets.dart';
import 'widgets/skin_3d.dart';
import 'widgets/skin_ui.dart';
import 'pages/skin_about_page.dart';
import 'pages/skin_help_page.dart';
import 'pages/skin_history_page.dart';
import 'pages/skin_home_page.dart';
import 'pages/skin_login_page.dart';
import 'pages/skin_notifications_page.dart';
import 'pages/skin_account_page.dart';
import 'pages/skin_profile_page.dart';
import 'pages/skin_result_page.dart';
import 'pages/skin_start_page.dart';
import 'pages/skin_settings_page.dart';
import 'pages/skin_legal_pages.dart';
import 'pages/skin_auth_choice_page.dart';
import 'pages/skin_onboarding_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _SkinSightBootstrap());
}

class _SkinSightBootstrap extends StatefulWidget {
  const _SkinSightBootstrap();

  @override
  State<_SkinSightBootstrap> createState() => _SkinSightBootstrapState();
}

class _SkinSightBootstrapState extends State<_SkinSightBootstrap> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      await Future.wait([
        SkinFontSettings.instance.load(),
        AuthSession.instance.load(),
        _initializeSupabase(),
      ]).timeout(const Duration(seconds: 2));
    } catch (error, stackTrace) {
      debugPrint('Startup preferences could not be loaded: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return const SkinSightApp(respectPersistedSession: true);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SkinTokens.theme(),
      home: const _SplashScreen(),
    );
  }
}

/// Layar pembuka singkat selama preferensi dimuat.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SkinPageBackground(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Skin3D(AppAssets.aloe3d, width: 170, height: 108),
              SizedBox(height: 14),
              SkinWordmark(fontSize: 32),
              SizedBox(height: 6),
              Text(
                'Kenali, catat, dan pahami kulitmu',
                style: TextStyle(color: SkinTokens.muted, fontSize: 14),
              ),
              SizedBox(height: 34),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeSupabase() async {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) return;
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );
}

class SkinSightApp extends StatelessWidget {
  const SkinSightApp({super.key, this.respectPersistedSession = false});

  final bool respectPersistedSession;

  bool _supabaseReady() {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabaseReady = _supabaseReady();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileData()),
        Provider<AuthService>(
          create: (_) =>
              supabaseReady ? SupabaseAuthService() : FakeAuthService(),
        ),
      ],
      child: AnimatedBuilder(
        animation: SkinFontSettings.instance,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute:
              respectPersistedSession && AuthSession.instance.isSignedIn
                  ? '/home'
                  : '/',
          theme: SkinTokens.theme(
            fontFamily: SkinFontSettings.instance.fontFamily,
          ),
          routes: {
            '/': (_) => const SkinStartPage(),
            '/home': (_) => const SkinHomePage(),
            '/education': (_) => const SkinHomePage(initialIndex: 1),
            // Kept as an alias so old deep links remain valid.
            '/catalog': (_) => const SkinHomePage(initialIndex: 1),
            '/about': (_) => const SkinAboutPage(),
            '/login': (_) => const SkinLoginPage(),
            '/register': (_) => const SkinLoginPage(initialRegisterMode: true),
            '/auth': (_) => const SkinAuthChoicePage(),
            '/onboarding': (_) => const SkinOnboardingPage(),
            '/help': (_) => const SkinHelpPage(),
            '/history': (_) => const SkinHistoryPage(),
            '/notifications': (_) => const SkinNotificationsPage(),
            '/profile': (_) => const SkinProfilePage(),
            '/account': (_) => const SkinAccountPage(),
            '/settings': (_) => const SkinSettingsPage(),
            '/privacy': (_) => const SkinPrivacyPage(),
            '/terms': (_) => const SkinTermsPage(),
            '/result': (_) => const SkinResultPage(),
          },
        ),
      ),
    );
  }
}
