import 'dart:math' as math;

import '../domain/scale_input.dart';
import '../domain/scale_policy.dart';
import '../domain/scale_result.dart';

/// Uniformly scales the reference frame so it is contained by the viewport.
final class ContainScalePolicy implements ScalePolicy {
  const ContainScalePolicy();

  @override
  ScaleResult resolve(ScaleInput input) {
    _validateSize(input.viewportSize.width, input.viewportSize.height, 'viewportSize');
    _validateSize(input.referenceSize.width, input.referenceSize.height, 'referenceSize');

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

  static void _validateSize(double width, double height, String name) {
    if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) {
      throw ArgumentError('$name must contain finite dimensions greater than zero.');
    }
  }
}
