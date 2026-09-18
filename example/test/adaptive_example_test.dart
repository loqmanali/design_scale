import 'package:design_scale_example/adaptive_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cases = <Size, String>{
    Size(375, 812): 'compact',
    Size(800, 1280): 'medium',
    Size(1440, 900): 'expanded',
  };

  for (final entry in cases.entries) {
    testWidgets('adaptive example renders ${entry.value}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = entry.key;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(const AdaptiveDemoApp());
      await tester.pumpAndSettle();
      expect(find.text('Layout: ${entry.value}'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (entry.value == 'compact') {
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      } else {
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      }
    });
  }

  testWidgets('notes survive a window-class change', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1280);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const AdaptiveDemoApp());
    final notes = find.byKey(const ValueKey('adaptive-notes'));
    await tester.ensureVisible(notes);
    await tester.enterText(notes, 'Keep this note');
    tester.testTextInput.hide();
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpAndSettle();
    expect(find.text('Keep this note'), findsOneWidget);
    expect(find.text('Layout: expanded'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
