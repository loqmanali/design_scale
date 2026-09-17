/// Optional bounds applied to a scale resolved by a `ScalePolicy`.
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
    _validate();

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

  void _validate() {
    final minValue = min;
    final maxValue = max;

    if (minValue != null && (!minValue.isFinite || minValue <= 0)) {
      throw StateError('ScaleLimits.min must be finite and greater than zero.');
    }
    if (maxValue != null && (!maxValue.isFinite || maxValue <= 0)) {
      throw StateError('ScaleLimits.max must be finite and greater than zero.');
    }
    if (minValue != null && maxValue != null && minValue > maxValue) {
      throw StateError('ScaleLimits.min cannot be greater than ScaleLimits.max.');
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ScaleLimits && other.min == min && other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);
}
