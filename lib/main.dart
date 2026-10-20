import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/auth_service.dart';
import 'models/profile_data.dart';
import 'models/font_settings.dart';
import 'models/auth_session.dart';
import 'theme/skin_theme.dart';
import 'pages/skin_history_page.dart';
import 'pages/skin_home_page.dart';
import 'pages/skin_login_page.dart';
import 'pages/skin_notifications_page.dart';
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
      home: const Scaffold(
        backgroundColor: SkinTokens.background,
        body: Center(
          child: CircularProgressIndicator(color: SkinTokens.primary),
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
          ).copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _NoPageTransitionsBuilder(),
                TargetPlatform.iOS: _NoPageTransitionsBuilder(),
                TargetPlatform.macOS: _NoPageTransitionsBuilder(),
                TargetPlatform.windows: _NoPageTransitionsBuilder(),
                TargetPlatform.linux: _NoPageTransitionsBuilder(),
                TargetPlatform.fuchsia: _NoPageTransitionsBuilder(),
              },
            ),
          ),
          routes: {
            '/': (_) => const SkinStartPage(),
            '/home': (_) => const SkinHomePage(),
            '/education': (_) => const SkinHomePage(initialIndex: 1),
            // Kept as an alias so old deep links remain valid.
            '/catalog': (_) => const SkinHomePage(initialIndex: 1),
            '/about': (_) => const SkinHomePage(initialIndex: 3),
            '/login': (_) => const SkinLoginPage(),
            '/register': (_) => const SkinLoginPage(initialRegisterMode: true),
            '/auth': (_) => const SkinAuthChoicePage(),
            '/onboarding': (_) => const SkinOnboardingPage(),
            '/help': (_) => const SkinHomePage(initialIndex: 2),
            '/history': (_) => const SkinHistoryPage(),
            '/notifications': (_) => const SkinNotificationsPage(),
            '/profile': (_) => const SkinProfilePage(),
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

class _NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
