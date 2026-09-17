/// Optional bounds applied to a scale resolved by a [ScalePolicy].
class ScaleLimits {
  const ScaleLimits({this.min, this.max})
    : assert(min == null || min > 0),
      assert(max == null || max > 0),
      assert(min == null || max == null || min <= max);

  /// Minimum allowed scale, or `null` for no lower bound.
  final double? min;

  /// Maximum allowed scale, or `null` for no upper bound.
  final double? max;

  /// Applies the configured bounds to [value].
  double apply(double value) {
    var result = value;

    final minValue = min;
    if (minValue != null && result < minValue) {
      result = minValue;
    }

    final maxValue = max;
    if (maxValue != null && result > maxValue) {
      result = maxValue;
    }

    return result;
  }
}
