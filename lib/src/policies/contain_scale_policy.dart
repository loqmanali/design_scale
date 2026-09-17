import 'dart:math' as math;

import '../domain/scale_input.dart';
import '../domain/scale_policy.dart';
import '../domain/scale_result.dart';

/// Uniformly scales the reference frame so it is contained by the viewport.
final class ContainScalePolicy implements ScalePolicy {
  const ContainScalePolicy();

  @override
  ScaleResult resolve(ScaleInput input) {
    final widthScale = input.viewportSize.width / input.referenceSize.width;
    final heightScale = input.viewportSize.height / input.referenceSize.height;
    final rawScale = math.min(widthScale, heightScale);

    return ScaleResult.fromRaw(
      rawScale: rawScale,
      viewportSize: input.viewportSize,
      referenceSize: input.referenceSize,
      limits: input.limits,
    );
  }
}
