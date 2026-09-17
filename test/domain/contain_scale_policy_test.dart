import 'dart:ui';

import 'package:design_scale/design_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContainScalePolicy', () {
    const policy = ContainScalePolicy();

    test('returns 1 when viewport matches reference size', () {
      final result = policy.resolve(
        const ScaleInput(
          viewportSize: Size(375, 812),
          referenceSize: Size(375, 812),
        ),
      );

      expect(result.scale, 1);
      expect(result.virtualSize, const Size(375, 812));
      expect(result.isClamped, isFalse);
    });

    test('uses the smaller axis ratio and preserves extra layout space', () {
      final result = policy.resolve(
        const ScaleInput(
          viewportSize: Size(800, 1280),
          referenceSize: Size(375, 812),
        ),
      );

      expect(result.scale, closeTo(1280 / 812, 0.000001));
      expect(result.virtualSize.height, closeTo(812, 0.000001));
      expect(result.virtualSize.width, greaterThan(375));
    });

    test('applies configured limits after raw scale resolution', () {
      final result = policy.resolve(
        const ScaleInput(
          viewportSize: Size(1000, 2000),
          referenceSize: Size(375, 812),
          limits: ScaleLimits(max: 1.2),
        ),
      );

      expect(result.scale, 1.2);
      expect(result.rawScale, greaterThan(1.2));
      expect(result.isClamped, isTrue);
    });
  });
}
