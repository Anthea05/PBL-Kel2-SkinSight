import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinsight/models/skin_recommendation.dart';
import 'package:skinsight/pages/skin_quiz_page.dart';
import 'package:skinsight/pages/skin_result_page.dart';
import 'package:skinsight/pages/skin_scan_page.dart';

SkinRecommendation _testRec() => SkinRecommendation.fromJson({
      'schema_version': '1.0',
      'tipe_kulit': 'Kombinasi (T-Zone)',
      'penjelasan_singkat':
          'Area dahi dan hidung cenderung berminyak, pipi relatif normal.',
      'zat_aktif_rekomendasi': [
        {'nama': 'Niacinamide', 'fungsi': 'Menyeimbangkan minyak.'},
        {'nama': 'Hyaluronic Acid', 'fungsi': 'Menjaga hidrasi.'},
      ],
      'zat_aktif_dihindari': ['Alkohol denat'],
      'rutinitas_harian': {
        'pagi': ['Cuci muka lembut.', 'Tabir surya.'],
        'malam': ['Cuci muka lembut.', 'Pelembap.'],
      },
      'perawatan_tambahan': ['Eksfoliasi 1x seminggu.'],
      'sumber_referensi': [],
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in const [Size(320, 568), Size(390, 844)]) {
    testWidgets('scan page has no overflow at ${size.width}px', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: SkinScanPage(enableCamera: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scan Wajah'), findsOneWidget);
      expect(find.byKey(const Key('capture-selfie')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('result page has no overflow at ${size.width}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(home: SkinResultPage(recommendation: _testRec())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hasil Rekomendasi'), findsOneWidget);
      expect(find.text('Rutinitas'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Zat aktif yang cocok'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Zat aktif yang cocok'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('disclaimer')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('save-result')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('result page handles 412px with long content', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(412, 915);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(home: SkinResultPage(recommendation: _testRec())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hasil Rekomendasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('capture controls visible without scrolling at 320px', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: SkinScanPage(enableCamera: false)),
    );
    await tester.pumpAndSettle();

    final shutter = find.byKey(const Key('capture-selfie'));
    expect(shutter, findsOneWidget);
    // Tombol shutter (sticky bar) harus di dalam viewport tanpa scroll.
    expect(tester.getBottomLeft(shutter).dy, lessThanOrEqualTo(568));
    expect(find.byKey(const Key('scan-gallery')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('routine toggle switches pagi and malam', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(home: SkinResultPage(recommendation: _testRec())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tabir surya.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('routine-toggle-malam')));
    await tester.pumpAndSettle();
    expect(find.text('Pelembap.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('finishing question five opens the scan page', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: SkinQuizPage(enableCamera: false)),
    );
    await tester.pumpAndSettle();

    // FR-05: tiap langkah wajib memilih jawaban sebelum Lanjut aktif.
    for (var question = 1; question <= 5; question++) {
      await tester.tap(find.byKey(const Key('quiz-answer-0')));
      await tester.pumpAndSettle();
      final continueButton = find.byKey(const Key('quiz-continue'));
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
    }

    expect(find.text('Scan Wajah'), findsOneWidget);
    expect(find.byKey(const Key('capture-selfie')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
