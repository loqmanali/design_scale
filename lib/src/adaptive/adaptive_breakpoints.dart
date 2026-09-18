import 'adaptive_window_class.dart';

/// Width boundaries in the unscaled window's logical pixels.
///
/// Defaults: compact < 600, medium >= 600 and < 840, expanded >= 840.
/// Configuration and input are validated by [classify] in all build modes.
class AdaptiveBreakpoints {
  const AdaptiveBreakpoints({
    this.compactEnd = 600,
    this.mediumEnd = 840,
  });

  /// Exclusive upper bound of the compact class.
  final double compactEnd;

  /// Exclusive upper bound of the medium class.
  final double mediumEnd;

  /// Classifies a finite, non-negative logical width.
  ///
  /// Zero is compact; a scaling viewport itself must have positive dimensions.
  /// Throws [ArgumentError] for invalid width or invalid boundaries.
  AdaptiveWindowClass classify(double width) {
    if (!compactEnd.isFinite || compactEnd <= 0) {
      throw ArgumentError.value(
        compactEnd,
        'compactEnd',
        'must be finite and greater than zero',
      );
    }
    if (!mediumEnd.isFinite || mediumEnd <= compactEnd) {
      throw ArgumentError.value(
        mediumEnd,
        'mediumEnd',
        'must be finite and greater than compactEnd',
      );
    }
    if (!width.isFinite || width < 0) {
      throw ArgumentError.value(
        width,
        'width',
        'must be finite and non-negative',
      );
    }

    if (width < compactEnd) {
      return AdaptiveWindowClass.compact;
    }
    if (width < mediumEnd) {
      return AdaptiveWindowClass.medium;
    }
    return AdaptiveWindowClass.expanded;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AdaptiveBreakpoints &&
            other.compactEnd == compactEnd &&
            other.mediumEnd == mediumEnd;
  }

  @override
  int get hashCode => Object.hash(compactEnd, mediumEnd);
}
