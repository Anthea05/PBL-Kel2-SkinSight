import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/profile_data.dart';
import 'theme/skin_theme.dart';
import 'pages/skin_history_page.dart';
import 'pages/skin_home_page.dart';
import 'pages/skin_login_page.dart';
import 'pages/skin_notifications_page.dart';
import 'pages/skin_profile_page.dart';
import 'pages/skin_result_page.dart';
import 'pages/skin_start_page.dart';

void main() => runApp(const SkinSightApp());

class SkinSightApp extends StatelessWidget {
  const SkinSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileData(),
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
          '/about': (_) => const SkinHomePage(initialIndex: 3),
          '/login': (_) => const SkinLoginPage(),
          '/help': (_) => const SkinHomePage(initialIndex: 2),
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
