import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinsight/pages/skin_quiz_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('quiz shows Breeze top bar (RED)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: SkinQuizPage(enableCamera: false)),
    );
    await tester.pumpAndSettle();

    // Gaya Breeze: counter ringkas + tombol close X, tanpa caption warisan.
    expect(find.text('1/5'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.text('Kuis Kondisi Kulit'), findsNothing);
    expect(find.text('Langkah 1 dari 5'), findsNothing);
    // Opsi 1-baris seperti referensi: deskripsi tidak dirender.
    expect(
      find.text('Dahi dan hidung mengilap, pipi normal.',
          skipOffstage: false),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('quiz Breeze flow advances to 2/5 (RED)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: SkinQuizPage(enableCamera: false)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quiz-answer-0')));
    await tester.pumpAndSettle();
    final cont = find.byKey(const Key('quiz-continue'));
    await tester.ensureVisible(cont);
    await tester.pumpAndSettle();
    await tester.tap(cont);
    await tester.pumpAndSettle();

    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('Langkah 2 dari 5'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
