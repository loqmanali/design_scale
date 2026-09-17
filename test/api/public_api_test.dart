import 'package:design_scale/design_scale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release-candidate core API remains usable from the package barrel', () {
    const policy = ContainScalePolicy();
    const limits = ScaleLimits(min: 0.75);
    const config = DesignScaleConfig(
      referenceSize: Size(400, 800),
      policy: policy,
      limits: limits,
    );
    const input = ScaleInput(
      viewportSize: Size(800, 1600),
      referenceSize: Size(400, 800),
      limits: limits,
    );

    final result = policy.resolve(input);

    expect(config.referenceSize, const Size(400, 800));
    expect(result.scale, 2);
    expect(result.virtualSize, const Size(400, 800));
    expect(result.isClamped, isFalse);
  });
}
