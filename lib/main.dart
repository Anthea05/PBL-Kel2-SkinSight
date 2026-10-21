import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/auth_service.dart';
import 'models/profile_data.dart';
import 'theme/skin_theme.dart';
import 'pages/skin_about_page.dart';
import 'pages/skin_help_page.dart';
import 'pages/skin_history_page.dart';
import 'pages/skin_home_page.dart';
import 'pages/skin_login_page.dart';
import 'pages/skin_notifications_page.dart';
import 'pages/skin_profile_page.dart';
import 'pages/skin_result_page.dart';
import 'pages/skin_start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  }
  runApp(const SkinSightApp());
}

class SkinSightApp extends StatelessWidget {
  const SkinSightApp({super.key});

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
          create: (_) => supabaseReady ? SupabaseAuthService() : FakeAuthService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SkinTokens.theme().copyWith(
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
          '/about': (_) => const SkinAboutPage(),
          '/login': (_) => const SkinLoginPage(),
          '/help': (_) => const SkinHelpPage(),
          '/history': (_) => const SkinHistoryPage(),
          '/notifications': (_) => const SkinNotificationsPage(),
          '/profile': (_) => const SkinProfilePage(),
          '/result': (_) => const SkinResultPage(),
        },
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
