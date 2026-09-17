import 'dart:ui' as ui;

import 'package:design_scale/design_scale.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'transforms foldable, keyboard, gesture, and accessibility geometry',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(820, 1200);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      MediaQueryData? observedMediaQuery;
      DesignScaleScope? observedScope;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(820, 1200),
            textScaler: TextScaler.linear(1.5),
            padding: EdgeInsets.only(top: 40),
            viewPadding: EdgeInsets.only(top: 40),
            viewInsets: EdgeInsets.only(bottom: 400),
            systemGestureInsets: EdgeInsets.symmetric(horizontal: 24),
            gestureSettings: DeviceGestureSettings(touchSlop: 18),
            highContrast: true,
            boldText: true,
            displayFeatures: <ui.DisplayFeature>[
              ui.DisplayFeature(
                bounds: Rect.fromLTWH(400, 0, 20, 1200),
                type: ui.DisplayFeatureType.hinge,
                state: ui.DisplayFeatureState.postureHalfOpened,
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: DesignScale(
              referenceSize: const Size(410, 600),
              child: Builder(
                builder: (context) {
                  observedMediaQuery = MediaQuery.of(context);
                  observedScope = DesignScaleScope.of(context);
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      );

      expect(observedScope, isNotNull);
      expect(observedScope!.result.scale, 2);
      expect(observedMediaQuery, isNotNull);
      expect(observedMediaQuery!.size, const Size(410, 600));
      expect(observedMediaQuery!.padding, const EdgeInsets.only(top: 20));
      expect(observedMediaQuery!.viewPadding, const EdgeInsets.only(top: 20));
      expect(
        observedMediaQuery!.viewInsets,
        const EdgeInsets.only(bottom: 200),
      );
      expect(
        observedMediaQuery!.systemGestureInsets,
        const EdgeInsets.symmetric(horizontal: 12),
      );
      expect(observedMediaQuery!.gestureSettings.touchSlop, 9);
      expect(observedMediaQuery!.textScaler.scale(10), 15);
      expect(observedMediaQuery!.highContrast, isTrue);
      expect(observedMediaQuery!.boldText, isTrue);
      expect(observedMediaQuery!.displayFeatures, hasLength(1));
      expect(
        observedMediaQuery!.displayFeatures.single.bounds,
        const Rect.fromLTWH(200, 0, 10, 600),
      );
    },
  );

  testWidgets('supports the production viewport matrix', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    const cases = <_ViewportCase>[
      _ViewportCase(
        name: 'reference portrait',
        viewport: Size(400, 800),
        expectedScale: 1,
        expectedVirtualSize: Size(400, 800),
      ),
      _ViewportCase(
        name: 'large portrait',
        viewport: Size(800, 1600),
        expectedScale: 2,
        expectedVirtualSize: Size(400, 800),
      ),
      _ViewportCase(
        name: 'split screen',
        viewport: Size(600, 800),
        expectedScale: 1,
        expectedVirtualSize: Size(600, 800),
      ),
      _ViewportCase(
        name: 'landscape',
        viewport: Size(800, 400),
        expectedScale: 0.5,
        expectedVirtualSize: Size(1600, 800),
      ),
    ];

    for (final viewportCase in cases) {
      tester.view.physicalSize = viewportCase.viewport;
      DesignScaleScope? observedScope;

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: viewportCase.viewport),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: DesignScale(
              referenceSize: const Size(400, 800),
              child: Builder(
                builder: (context) {
                  observedScope = DesignScaleScope.of(context);
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      );

      expect(
        observedScope!.result.scale,
        viewportCase.expectedScale,
        reason: viewportCase.name,
      );
      expect(
        observedScope!.result.virtualSize,
        viewportCase.expectedVirtualSize,
        reason: viewportCase.name,
      );
    }
  });
}

final class _ViewportCase {
  const _ViewportCase({
    required this.name,
    required this.viewport,
    required this.expectedScale,
    required this.expectedVirtualSize,
  });

  final String name;
  final Size viewport;
  final double expectedScale;
  final Size expectedVirtualSize;
}
