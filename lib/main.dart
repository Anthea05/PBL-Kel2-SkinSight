import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/auth_service.dart';
import 'models/profile_data.dart';
import 'pages/skin_help_page.dart';
import 'pages/skin_history_page.dart';
import 'pages/skin_home_page.dart';
import 'pages/skin_login_page.dart';
import 'pages/skin_profile_page.dart';
import 'pages/skin_result_page.dart';
import 'pages/skin_start_page.dart';
import 'theme/app_theme.dart';

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
        theme: buildSkinSightTheme(),
        routes: {
          '/': (_) => const SkinStartPage(),
          '/home': (_) => const SkinHomePage(),
          '/login': (_) => const SkinLoginPage(),
          '/help': (_) => const SkinHelpPage(),
          '/history': (_) => const SkinHistoryPage(),
          '/profile': (_) => const SkinProfilePage(),
          '/result': (_) => const SkinResultPage(),
        },
      ),
    );
  }
}
