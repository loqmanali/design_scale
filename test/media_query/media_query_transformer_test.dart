import 'dart:ui' as ui;

import 'package:design_scale/src/media_query/media_query_transformer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transforms spatial metrics and preserves platform metrics', () {
    const original = MediaQueryData(
      size: Size(800, 1600),
      devicePixelRatio: 3,
      textScaler: TextScaler.linear(1.5),
      padding: EdgeInsets.fromLTRB(20, 40, 20, 60),
      viewPadding: EdgeInsets.fromLTRB(24, 48, 24, 72),
      viewInsets: EdgeInsets.only(bottom: 600),
      systemGestureInsets: EdgeInsets.all(16),
      gestureSettings: DeviceGestureSettings(touchSlop: 24),
      accessibleNavigation: true,
      highContrast: true,
      displayFeatures: <ui.DisplayFeature>[
        ui.DisplayFeature(
          bounds: Rect.fromLTWH(390, 0, 20, 1600),
          type: ui.DisplayFeatureType.hinge,
          state: ui.DisplayFeatureState.postureHalfOpened,
        ),
      ],
    );

    final transformed = MediaQueryTransformer.transform(
      data: original,
      scale: 2,
      virtualSize: const Size(400, 800),
    );

    expect(transformed.size, const Size(400, 800));
    expect(transformed.padding, const EdgeInsets.fromLTRB(10, 20, 10, 30));
    expect(
      transformed.viewPadding,
      const EdgeInsets.fromLTRB(12, 24, 12, 36),
    );
    expect(transformed.viewInsets, const EdgeInsets.only(bottom: 300));
    expect(transformed.systemGestureInsets, const EdgeInsets.all(8));
    expect(transformed.gestureSettings.touchSlop, 12);
    expect(transformed.displayFeatures, hasLength(1));
    expect(
      transformed.displayFeatures.single.bounds,
      const Rect.fromLTWH(195, 0, 10, 800),
    );
    expect(
      transformed.displayFeatures.single.type,
      ui.DisplayFeatureType.hinge,
    );
    expect(
      transformed.displayFeatures.single.state,
      ui.DisplayFeatureState.postureHalfOpened,
    );

    expect(transformed.devicePixelRatio, original.devicePixelRatio);
    expect(transformed.textScaler.scale(10), 15);
    expect(transformed.accessibleNavigation, isTrue);
    expect(transformed.highContrast, isTrue);
  });

  test('rejects a non-positive scale', () {
    expect(
      () => MediaQueryTransformer.transform(
        data: const MediaQueryData(),
        scale: 0,
        virtualSize: const Size(400, 800),
      ),
      throwsArgumentError,
    );
  });
}
