import 'dart:ui' as ui;

import 'package:design_scale/src/media_query/viewport_geometry_transformer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewportGeometryTransformer', () {
    test('converts insets and rectangles into virtual coordinates', () {
      expect(
        ViewportGeometryTransformer.toVirtualInsets(
          const EdgeInsets.fromLTRB(20, 40, 60, 80),
          2,
        ),
        const EdgeInsets.fromLTRB(10, 20, 30, 40),
      );

      expect(
        ViewportGeometryTransformer.toVirtualRect(
          const Rect.fromLTWH(400, 0, 20, 1200),
          2,
        ),
        const Rect.fromLTWH(200, 0, 10, 600),
      );
    });

    test('transforms display feature bounds and preserves metadata', () {
      const features = <ui.DisplayFeature>[
        ui.DisplayFeature(
          bounds: Rect.fromLTWH(400, 0, 20, 1200),
          type: ui.DisplayFeatureType.hinge,
          state: ui.DisplayFeatureState.postureHalfOpened,
        ),
        ui.DisplayFeature(
          bounds: Rect.fromLTWH(0, 600, 820, 0),
          type: ui.DisplayFeatureType.fold,
          state: ui.DisplayFeatureState.postureFlat,
        ),
      ];

      final transformed =
          ViewportGeometryTransformer.toVirtualDisplayFeatures(features, 2);

      expect(transformed, hasLength(2));
      expect(
        transformed.first.bounds,
        const Rect.fromLTWH(200, 0, 10, 600),
      );
      expect(transformed.first.type, ui.DisplayFeatureType.hinge);
      expect(
        transformed.first.state,
        ui.DisplayFeatureState.postureHalfOpened,
      );
      expect(
        transformed.last.bounds,
        const Rect.fromLTWH(0, 300, 410, 0),
      );
      expect(transformed.last.type, ui.DisplayFeatureType.fold);
      expect(transformed.last.state, ui.DisplayFeatureState.postureFlat);
    });

    test('preserves identity when no geometry conversion is required', () {
      const features = <ui.DisplayFeature>[];
      const settings = DeviceGestureSettings(touchSlop: 18);

      expect(
        identical(
          ViewportGeometryTransformer.toVirtualDisplayFeatures(features, 2),
          features,
        ),
        isTrue,
      );
      expect(
        identical(
          ViewportGeometryTransformer.toVirtualGestureSettings(settings, 1),
          settings,
        ),
        isTrue,
      );
    });

    test('converts gesture thresholds into virtual coordinates', () {
      const settings = DeviceGestureSettings(touchSlop: 18);

      final transformed =
          ViewportGeometryTransformer.toVirtualGestureSettings(settings, 2);

      expect(transformed.touchSlop, 9);
      expect(transformed.panSlop, 18);
    });

    test('rejects invalid scale values', () {
      expect(
        () => ViewportGeometryTransformer.toVirtualRect(Rect.zero, 0),
        throwsArgumentError,
      );
      expect(
        () => ViewportGeometryTransformer.toVirtualInsets(
          EdgeInsets.zero,
          double.nan,
        ),
        throwsArgumentError,
      );
    });
  });
}
