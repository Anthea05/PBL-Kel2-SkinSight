import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/profile_data.dart';
import 'pages/skin_help_page.dart';
import 'pages/skin_history_page.dart';
import 'pages/skin_home_page.dart';
import 'pages/skin_login_page.dart';
import 'pages/skin_profile_page.dart';
import 'pages/skin_result_page.dart';
import 'pages/skin_start_page.dart';
import 'theme/app_theme.dart';

void main() => runApp(const SkinSightApp());

class SkinSightApp extends StatelessWidget {
  const SkinSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileData(),
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
