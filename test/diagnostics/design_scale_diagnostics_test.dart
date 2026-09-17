import 'package:design_scale/design_scale.dart';
import 'package:design_scale/design_scale_debug.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('captures the current scale runtime state', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(800, 1600)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DesignScale(
            referenceSize: Size(400, 800),
            child: _DiagnosticsProbe(),
          ),
        ),
      ),
    );

    final diagnostics = _DiagnosticsProbe.lastValue;
    if (diagnostics == null) {
      fail('Expected DesignScale diagnostics to be captured.');
    }

    expect(diagnostics.referenceSize, const Size(400, 800));
    expect(diagnostics.viewportSize, const Size(800, 1600));
    expect(diagnostics.virtualSize, const Size(400, 800));
    expect(diagnostics.scale, 2);
    expect(diagnostics.policyName, 'ContainScalePolicy');
    expect(diagnostics.toMultilineString(), contains('scale: 2.0000'));
  });

  testWidgets('renders the debug overlay below DesignScale', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(400, 800)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DesignScale(
            referenceSize: Size(400, 800),
            child: DesignScaleDebugOverlay(
              child: SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('DesignScale'), findsOneWidget);
    expect(find.textContaining('ContainScalePolicy'), findsOneWidget);
  });
}

final class _DiagnosticsProbe extends StatelessWidget {
  const _DiagnosticsProbe();

  static DesignScaleDiagnostics? lastValue;

  @override
  Widget build(BuildContext context) {
    lastValue = DesignScaleDiagnostics.of(context);
    return const SizedBox.expand();
  }
}
