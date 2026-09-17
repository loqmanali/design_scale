import 'package:design_scale/design_scale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cases = <_GoldenCase>[
    _GoldenCase(
      name: 'reference_portrait',
      viewport: Size(160, 320),
    ),
    _GoldenCase(
      name: 'large_portrait',
      viewport: Size(320, 640),
    ),
    _GoldenCase(
      name: 'split_width',
      viewport: Size(320, 320),
    ),
    _GoldenCase(
      name: 'landscape',
      viewport: Size(320, 160),
    ),
  ];

  for (final goldenCase in cases) {
    testWidgets('renders ${goldenCase.name} consistently', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = goldenCase.viewport;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: goldenCase.viewport),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: RepaintBoundary(
              key: boundaryKey,
              child: DesignScale(
                referenceSize: const Size(160, 320),
                child: const ColoredBox(
                  color: Color(0xFFFFFFFF),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        width: 20,
                        height: 20,
                        child: ColoredBox(color: Color(0xFFFF0000)),
                      ),
                      Align(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: ColoredBox(color: Color(0xFF00FF00)),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width: 40,
                        height: 40,
                        child: ColoredBox(color: Color(0xFF0000FF)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('${goldenCase.name}.png'),
      );
    });
  }
}

final class _GoldenCase {
  const _GoldenCase({
    required this.name,
    required this.viewport,
  });

  final String name;
  final Size viewport;
}
