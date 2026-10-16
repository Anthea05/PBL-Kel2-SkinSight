import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Masuk ke Beranda via form login (tanpa env Supabase, app memakai
/// [FakeAuthService] sehingga submit dengan akun prefill langsung masuk).
Future<void> enterHome(WidgetTester tester) async {
  final startButton = find.byKey(const Key('start-button'));
  await tester.ensureVisible(startButton);
  await tester.pumpAndSettle();
  await tester.tap(startButton);
  await tester.pumpAndSettle();

  final submitButton = find.byKey(const Key('login-submit'));
  await tester.ensureVisible(submitButton);
  await tester.pumpAndSettle();
  await tester.tap(submitButton);
  await tester.pumpAndSettle();
}
