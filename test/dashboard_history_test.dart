import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinsight/data/skin_history_repository.dart';
import 'package:skinsight/main.dart';
import 'package:skinsight/models/skin_analysis.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Lihat Semua opens history page (RED)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const SkinSightApp());
    await tester.pumpAndSettle();
    await enterHome(tester);

    final seeAll = find.byKey(const Key('open-history-all'));
    await tester.ensureVisible(seeAll);
    await tester.pumpAndSettle();
    await tester.tap(seeAll);
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Analisis'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard scan card refreshes after new scan (RED)',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const SkinSightApp());
    await tester.pumpAndSettle();
    await enterHome(tester);
    await tester.pumpAndSettle();

    expect(find.text('82/100'), findsOneWidget);

    // Tanpa pump, Future.delayed fake tidak maju — majukan waktu manual.
    final pendingSave = SkinHistoryRepository.instance.saveAnalysis(
      SkinAnalysis(
        id: 'scan-test-refresh',
        analyzedAt: DateTime(2026, 10, 9, 12),
        score: 95,
        title: 'Refresh Probe',
        skinType: 'Refresh Probe',
        oil: 10,
        pores: 10,
        acne: 10,
        redness: 10,
        hydration: 95,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await pendingSave;

    expect(find.text('95/100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
